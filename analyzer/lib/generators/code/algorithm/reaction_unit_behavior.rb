module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Provides logic for units which uses when reaction find algorithm builds
        module ReactionUnitBehavior
        protected

          # Gets the original concept spec from current unique dependent spec
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom for which the original concept spec will be returned
          # @return [Concept::Spec | Concept::SpecificSpec | Concept::VeiledSpec]
          #   the original concept spec
          def concept_spec(atom)
            dept_spec_for(atom).spec
          end

        private

          # Compares dependent specie with specie from other unit
          # @param [BaseUnit] other unit with which spec the own spec will be compared
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   own_atom the atom of current unit
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   other_atom the atom of other unit
          # @return [Boolean] are original concept species from current and other units
          #   same or not
          def same_specs?(other, own_atom, other_atom)
            concept_spec(own_atom) == other.concept_spec(other_atom)
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
              [unit.concept_spec(atom), atom]
            end

            dept_reaction.relation_between(*pair_of_specs_atoms)
          end

          # Gets the engine framework class for reactant specie
          # @return [String] the engine framework class for reactant specie
          def specie_type
            'SpecificSpec'
          end
        end

      end
    end
  end
end
