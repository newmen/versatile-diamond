module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # The instance of class could defines all neccessary variables and calls
        # engine framework method for create a reaction which was found
        class ReactionCreatorUnit
          include CommonCppExpressions

          # Initializes the creator
          # @param [Organizers::AtomClassifier] classifier for get the role of atom
          #   in undefined species
          # @param [NameRemember] namer the remember of using names of variables
          # @param [TypicalReaction] reaction which uses in current building algorithm
          # @param [Array] species_pairs the pairs of all previously defined unique
          #   species and correspond dependent species which uses for getting defined
          #   atoms
          def initialize(classifier, namer, reaction, species_pairs)
            @classifier = classifier
            @namer = namer
            @reaction = reaction
            @species_pairs = species_pairs.sort_by(&:last)
          end

          # Gets the code lines for reaction creation
          # @return [String] the lines by which the reaction will be created
          def lines
            if @species_pairs.size == 1
              create_line
            else
              define_target_species_variable_line + create_line
            end
          end

        private

          attr_reader :namer

          def target_species
            @species_pairs.map(&:last)
          end

          # Gets the cpp code string with creation of target reaction
          # @return [String] the cpp code line with creation target reaction call
          def create_line
            species_var_name = namer.name_of(target_species)
            code_line("create<#{@reaction.class_name}>(#{species_var_name});")
          end

          # Gets the list of correspond anchor atoms
          # @param [Organizers::DependentWrappedSpec] dept_spec see at
          #   #spec_by_role_call same argument
          # @param [UniqueSpecie] specie see at #spec_by_role_call same argument
          # @return [Array] the array of correspond anchor atoms
          def anchors(dept_spec, specie)
            if specie.spec == dept_spec
              dept_spec.anchors
            else
              mirror = specie.spec.mirror_to(dept_spec)
              specie.spec.anchors.map { |a| mirror[a] }
            end
          end

          # Finds previously defined atom
          # @param [Organizers::DependentWrappedSpec] dept_spec see at
          #   #spec_by_role_call same argument
          # @param [UniqueSpecie] specie see at #spec_by_role_call same argument
          # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which already defined before
          def atom_of(dept_spec, specie)
            anchors(dept_spec, specie).find { |a| namer.name_of(a) }
          end

          # Makes code which gets target specie instance from passed atom
          # @param [Organizers::DependentWrappedSpec] dept_spec which uses for get an
          #   atom from which the specie instance will be gotten
          # @param [UniqueSpecie] specie which simulation instance will be gotten
          # @return [String] the string of cpp code with specByRole call
          def spec_by_role_call(dept_spec, specie)
            atom = atom_of(dept_spec, specie)
            atom_var_name = namer.name_of(atom)
            specie_class_name = specie.class_name
            atom_role = @classifier.index(dept_spec, atom)
            "#{atom_var_name}->specByRole<#{specie_class_name}>(#{atom_role})"
          end

          # Gets the line with definition of target species array variable
          # @return [String] th ecpp code line with definition of target species var
          def define_target_species_variable_line
            items = @species_pairs.map do |dept_spec, specie|
              namer.name_of(specie) || spec_by_role_call(dept_spec, specie)
            end

            namer.reassign('target', target_species)
            define_var_line('SpecificSpec *', target_species, items)
          end
        end

      end
    end
  end
end
