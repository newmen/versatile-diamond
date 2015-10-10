module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code
      module Algorithm

        # The instance of class could defines all neccessary variables and calls
        # engine framework method for concretize side reaction which was found
        class ReactionCheckLateralsCreatorUnit < SingleLateralReactionCreatorUnit
          include SpecificSpecDefiner

          # The name of variable where stored pointer to neighbour reaction
          NBR_REACTION_NAME = 'nbrReaction'.freeze
          # The namve of variable where stored pointer to single lateral reaction
          CHUNK_NAME = 'chunk'.freeze

          # Initializes the creator
          # @param [NameRemember] namer the remember of using names of variables
          # @param [LateralReaction] lat_react which will created by current block
          # @param [LateralChunk] lat_chks which provides common links graph
          # @param [Array] sdpcs the list of sidepiece species which will passed to
          #   constructor of creating lateral reaction (with atoms)
          # @param [Array] rectns the list of target species from which lateral
          #   reactions will check (with atoms)
          def initialize(namer, lat_react, lat_chks, sdpcs, rectns)
            super(namer, lat_react, rectns.map(&:first))
            @lateral_chunks = lat_chks
            @sidepieces = sdpcs.map(&:first).sort.uniq

            @sidepieces_with_atoms = concepts(sdpcs)
            @reactants_with_atoms = concepts(rectns)
          end

          # Gets the cpp code lines with concretization of lateral reactions
          # @return [String] the cpp code lines with concretization reaction call
          def lines
            blocks = checking_reactions.map do |lateral_reaction|
              checkout_reaction_block(lateral_reaction)
            end

            blocks << checkout_reaction_block(main_reaction, lateral: false)
            blocks.join
          end

        private

          # Collects concepts from passed list of pairs
          # @param [Array] pairs the list of unique specie and their atoms
          # @return [Array] the list of concept species and their atoms
          def concepts(pairs)
            pairs.map { |uniq_specie, atom| [uniq_specie.proxy_spec, atom] }
          end

          # Gets typical reaction of current algorithm
          # @return [TypicalReaction] the main reaction
          def main_reaction
            @lateral_chunks.reaction
          end

          # Gets ordered list of checking lateral reactions
          # @return [Array] the list of reactions which will checked
          def checking_reactions
            arguments = [creating_reaction] + sidepiece_species.map(&:original)
            @lateral_chunks.unconcrete_affixes_without(*arguments)
          end

          # Gets one cpp code line with concretization of lateral reaction
          # @param [String] parent_inst_call the string of calling parent reaction
          # @return [String] one cpp code line with concretization reaction call
          def create_line(parent_inst_call)
            value = alloc_str(parent_inst_call)
            code_line("SingleLateralReaction *#{CHUNK_NAME} = #{value};")
          end

          # Gets scope cpp code lines with concretization of lateral reaction
          # @param [String] parent_inst_call the string of calling parent reaction
          # @return [String] scope cpp code lines with concretization reaction call
          def scope_create_lines(parent_inst_call, lateral: true)
            code_condition(NBR_REACTION_NAME) do
              (lateral ? assert_havent_line : '') +
                create_line(parent_inst_call) +
                code_line("#{NBR_REACTION_NAME}->concretize(#{CHUNK_NAME});") +
                code_line("return;") # just from iteration lambda
            end
          end

          # Gets line of code with assertion that current sidepiece haven't lateral
          # reaction
          #
          # @return [String] the assertion code line
          def assert_havent_line
            fail 'Too many sidepiece species' if sidepiece_species.size > 1
            have_call = "#{sidepiece_var_name}->haveReaction(#{NBR_REACTION_NAME})"
            code_line("assert(!#{have_call});")
          end

          # Gets checkout reaction block
          # @param [TypicalReaction | LateralReaction] reaction which will checked out
          # @option [Boolean] :lateral flag that indicates is main reaction or not
          # @return [String] the cpp code block
          def checkout_reaction_block(reaction, lateral: true)
            parent_inst_call = NBR_REACTION_NAME
            parent_inst_call += '->parent()' if lateral

            code_scope do
              checkout_reaction_line(reaction) +
                scope_create_lines(parent_inst_call, lateral: lateral)
            end
          end

          # Gets checkout reaction line
          # @param [TypicalReaction | LateralReaction] reaction which will checked out
          # @return [String] the cpp code line
          def checkout_reaction_line(reaction)
            lvalue = "#{reaction.class_name} *#{NBR_REACTION_NAME}"
            rvalue = checkout_reaction_call(reaction)
            code_line("#{lvalue} = #{rvalue};")
          end

          # Gets string with checkout reaction engine call
          # @param [TypicalReaction | LateralReaction] reaction which will checked out
          # @return [String] the cpp code string with call
          def checkout_reaction_call(reaction)
            if species.all_equal?
              # 123
              checking_species = [other_side_species, sidepiece_species].map(&:first)
              if has_same_reaction?(*checking_species)
                checkout_reaction_without_two(reaction, checking_species)
              else
                checkout_reaction_from_one(reaction)
              end
            else
              checkout_reaction_with_two(reaction, other_side_species[0..1])
            end
          end

          # Gets call which checks reaction from just one target specie
          # @param [TypicalReaction | LateralReaction] reaction which will checked out
          # @return [String] the cpp code string with call
          def checkout_reaction_from_one(reaction)
            var_name = namer.name_of(other_side_species.first)
            "#{var_name}->checkoutReaction<#{reaction.class_name}>()"
          end

          # Gets call which checks reaction by two species
          # @param [String] suffix of checkout method
          # @param [TypicalReaction | LateralReaction] reaction which will checked out
          # @return [String] the cpp code string with call
          def checkout_reaction_from_two(suffix, reaction, species)
            var_names = species.map { |specie| namer.name_of(specie) }
            method_name = "checkoutReaction#{suffix}<#{reaction.class_name}>"
            "#{var_names[0]}->#{method_name}(#{var_names[1]})"
          end

          # Gets call which checks reaction from two target species
          # @param [TypicalReaction | LateralReaction] reaction which will checked out
          # @return [String] the cpp code string with call
          def checkout_reaction_with_two(reaction, species)
            checkout_reaction_from_two('With', reaction, species)
          end

          # Gets call which checks reaction from not two target species
          # @param [TypicalReaction | LateralReaction] reaction which will checked out
          # @return [String] the cpp code string with call
          def checkout_reaction_without_two(reaction, species)
            checkout_reaction_from_two('Without', reaction, species)
          end

          # Gets list of sidepiece species which will passed to creating lateral
          # reaction
          #
          # @return [Array] the list of sidepiece species
          def sidepiece_species
            @sidepieces
          end

          # Checks that main reaction has another reactant which same as sidepiece
          # specie
          #
          # @param [UniqueSpecie] target_spece is one of reaction reactant
          # @param [UniqueSpecie] side_specie the specie with which another target will
          #   be compared
          # @return [Boolean] is exist another same target or not
          def has_same_reaction?(target_specie, side_specie)
            return false if @lateral_chunks.mono_reactant?

            target_pairs = select_concepts(target_specie, @reactants_with_atoms)
            sidepiece_pairs = select_concepts(side_specie, @sidepieces_with_atoms)

            other_rels = select_rels(target_pairs) do |spec, s, _|
              @lateral_chunks.target_spec?(s) && spec != s
            end

            sidepiece_rels = select_rels(target_pairs) do |_, *sa|
              sidepiece_pairs.include?(sa)
            end

            other_rels.any? do |(spec, atom), rel|
              sidepiece_rels.any? do |(s, a), r|
                next false unless rel == r && spec.same?(s) && atom.same?(a)

                dept_spec = side_specie.proxy_spec
                apt = atom_properties(dept_spec.clone_with_replace(spec), atom)
                aps = atom_properties(dept_spec, a)

                apt == aps
              end
            end
          end

          # Selects pairs where concepts specs same as spec in passed unique specie
          # @param [UniqueSpecie] specie from which the concept spec will compared with
          #   each spec from pairs
          # @param [Array] pairs the list of concept specs with atoms
          # @return [Array] list of selected pairs
          def select_concepts(specie, pairs)
            spec = specie.proxy_spec.spec
            pairs.select { |s, _| s == spec }
          end

          # Selects relations from lateral chunks links which corresponds to pairs from
          # passed list
          #
          # @param [Array] pairs the list of concept specs with atoms
          # @yield [Spec, Spec, Atom] iterates spec from pair, and spec and atom from
          #   relation
          # @return [Array] the list of selected relations
          def select_rels(pairs, &block)
            pairs.reduce([]) do |acc, spec_atom|
              spec, _ = spec_atom
              acc + @lateral_chunks.clean_links[spec_atom].select do |sa, _|
                block[spec, *sa]
              end
            end
          end
        end

      end
    end
  end
end
