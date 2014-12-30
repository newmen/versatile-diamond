module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code
      module Algorithm

        # Unit for bulding code that depends from reactant specie
        class ReactantUnit < SingleSpecieUnit
          include ReactionUnitBehavior

          # Initializes the reactant unit
          # @param [Array] args the arguments of #super method
          # @param [DependentSpecReaction] dept_reaction by which the relations between
          #   atoms will be checked
          def initialize(*args, dept_reaction)
            super(*args)
            @dept_reaction = dept_reaction
          end

          # Assigns the name for internal reactant specie, that it could be used when
          # the algorithm generates
          def first_assign!
            namer.assign(SpeciesReaction::ANCHOR_SPECIE_NAME, target_specie)
          end

          # Prepares reactant instance for reaction creation
          # @yield should get cpp code string which is body of checking
          # @return [String] the cpp code string
          def check_symmetries(clojure_on_scope: false, &block)
            if symmetric?
              each_symmetry_lambda(clojure_on_scope: clojure_on_scope, &block)
            else
              block.call
            end
          end

          # Checks additional atoms by which the grouped graph was extended
          # @yield should get cpp code string which is body of checking
          # @return [String] the cpp code string
          def check_additions(&block)
            define_target_specie_line +
              check_symmetries(clojure_on_scope: true) do
                ext_atoms_condition(&block)
              end
          end

          def inspect
            "RU:(#{inspect_specie_atoms_names}])"
          end

        protected

          # Gets the list of atoms which belongs to anchors of target concept
          # @return [Array] the list of atoms that belonga to anchors
          # @override
          def role_atoms
            anchors = dept_reaction.clean_links.keys
            diff = atoms.select { |a| anchors.include?(spec_atom_key(a)) }
            diff.empty? ? atoms : diff
          end

        private

          attr_reader :dept_reaction

          # Checks that internal target specie is symmetric by target atoms
          # @return [Boolean] is symmetric or not
          def symmetric?
            symmetric_atoms = atoms.select { |a| target_specie.symmetric_atom?(a) }
            return false if symmetric_atoms.size == 0
            return true unless role_atoms == symmetric_atoms

            links = dept_reaction.clean_links
            other_spec_atoms = symmetric_atoms.flat_map do |a|
              links[spec_atom_key(a)].map(&:first)
            end

            other_groups = other_spec_atoms.groups(&:first)
            many_others = other_groups.select { |group| group.size > 1 }
            return false if many_others.empty?

            # if other side atoms are symmetric too then current symmetric isn't
            # significant
            !many_others.any? do |group|
              group.all? do |(s, a), _|
                specie_class(s).symmetric_atom?(a)
              end
            end
          end

          # Gets the correct key of reaction links for passed atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom for which the key will be returned
          # @ return [Array] the key of reaction links graph
          def spec_atom_key(atom)
            [original_spec.spec, atom]
          end

          # Gets the defined anchor atom for target specie
          # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   the available anchor atom
          def avail_anchor
            original_specie.spec.anchors.find do |a|
              namer.name_of(a) && !original_specie.symmetric_atom?(a)
            end
          end

          # Gets the checking block for atoms by which the grouped graph was extended
          # @yield should get cpp code string which is body of checking
          # @return [String] the cpp code string
          def ext_atoms_condition(&block)
            compares = atoms.map do |atom|
              op = ext_atom?(atom) ? '!=' : '=='
              "#{namer.name_of(atom)} #{op} #{atom_from_own_specie_call(atom)}"
            end

            code_condition(compares.join(' && '), &block)
          end

          # Checks that passed atom is additional and was used when grouped graph has
          # extended
          #
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which will be checked
          # @return [Boolean] is additional atom or not
          def ext_atom?(atom)
            !dept_reaction.clean_links.include?([original_spec.spec, atom])
          end

          # Gets the code string with getting the target specie from atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom from which the target specie will be gotten
          # @return [String] cpp code string with engine framework method call
          # @override
          def spec_by_role_call(atom)
            super(atom, target_specie, atom)
          end

          # Gets code line with defined anchors atoms for each neighbours operation
          # @return [String] the code line with defined achor atoms variable
          def define_nbrs_specie_anchors_lines
            define_nbrs_anchors_line
          end
        end

      end
    end
  end
end
