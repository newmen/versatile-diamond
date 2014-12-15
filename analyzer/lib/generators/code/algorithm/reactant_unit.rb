module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Unit for bulding code that depends from reactant specie
        class ReactantUnit < SingleSpecieUnit

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
          def check_symmetries(&block)
            if symmetric?
              each_symmetry_lambda(&block)
            else
              block.call
            end
          end

          def inspect
            "RU:(#{inspect_specie_atoms_names}])"
          end

        private

          # Checks that internal target specie is symmetric by target atoms
          # @return [Boolean] is symmetric or not
          def symmetric?
            atoms.any? { |a| target_specie.symmetric_atom?(a) }
          end

          # Gets code string with call getting atom from target specie
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which will be used for get an index from target specie
          # @return [String] code where atom getting from target specie
          # @override
          def atom_from_specie_call(atom)
            super(target_specie, atom)
          end

          # Gets code line with defined anchors atoms for each neighbours operation
          # @return [String] the code line with defined achor atoms variable
          def define_nbrs_specie_anchors_lines
            define_nbrs_anchors_line
          end

          # Also checks the relations between atoms of other unit
          # @param [String] condition_str see at #super same argument
          # @param [BaseUnit] other see at #super same argument
          # @return [String] the extended condition
          # @override
          def append_check_other_relations(_condition_str, other)
            ops = other.atoms.combination(2).map { |pair| [other, other].zip(pair) }
            append_check_bond_conditions(super, ops)
          end

          # Gets relation between spec-atom instances which extracts from passed array
          # of pairs
          #
          # @param [Array] pair_of_units_with_atoms the array of two items where each
          #   element is array where first item is target unit and second item is atom
          # @return [Concepts::Bond] the relation between passed spec-atom instances or
          #   nil if relation isn't presented
          def relation_between(*pair_of_units_with_atoms)
            pair_of_specs_atoms = pair_of_units_with_atoms.map do |unit, atom|
              [unit.original_spec.spec, atom]
            end
            @dept_reaction.relation_between(*pair_of_specs_atoms)
          end

          # Gets the engine framework class for reactant specie
          # @return [String] the engine framework class for reactant specie
          # @override
          def specie_type
            'SpecificSpec'
          end
        end

      end
    end
  end
end
