module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Provides common logic for units which uses when reaction algorithm builds
        module ReactantUnitCommonBehavior
        protected

          # Gets the original concept spec from current unique dependent spec
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom for which the original concept spec will be returned
          # @return [Concept::Spec | Concept::SpecificSpec | Concept::VeiledSpec]
          #   the original concept spec
          def concept_spec(atom)
            dept_spec_for(atom).spec
          end

          # Checks that other unit has an atom which also available by passed relation
          # and if is truthy then returns linked atom
          #
          # @param [BaseUnit] other unit for which the atom second will be checked
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   own_atom the atom of current unit for which the relations will be checked
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   other_atom the atom from other unit which uses for comparing original
          #   species
          # @param [Concepts::Bond] relation which existance will be checked
          # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   the atom which same as last of passed atoms and available by relation, or
          #   nil if linked atom isn't same
          def same_linked_atom(other, own_atom, other_atom, relation)
            return nil if same_specs?(other, own_atom, other_atom)

            linked_atom = relation_with(own_atom, relation)
            return nil unless linked_atom

            pairs = [
              [dept_spec_for(own_atom), linked_atom],
              [other.dept_spec_for(other_atom), other_atom]
            ]

            props = pairs.map do |dept_spec, atom|
              Organizers::AtomProperties.new(dept_spec, atom)
            end

            props.permutation(2).any? { |f, s| f.include?(s) } ? linked_atom : nil
          end

          # Gets the cpp code string with comparison the passed atoms
          # @param [UniqueSpecie] specie from which the linked atom will be got
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   linked_atom the atom from target specie which will be compared
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   neighbour_atom the atom from another specie which will be compared
          # @return [String] the cpp code string with comparison the passed atoms
          #   between each other
          def not_own_atom_condition(specie, linked_atom, neighbour_atom)
            specie_call = atom_from_specie_call(specie, linked_atom)
            "#{name_of(neighbour_atom)} != #{specie_call}"
          end

        private

          # Gets the code string with getting the target specie from atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom from which the target specie will be gotten
          # @return [String] cpp code string with engine framework method call
          # @override
          def spec_by_role_call(atom)
            super(atom, uniq_specie_for(atom), atom)
          end

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

            relations_checker.relation_between(*pair_of_specs_atoms)
          end

          # hecks the atom linked with passed atom by passed relation
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom from which the linked atom will be checked
          # @param [Concepts::Bond] relation by which the linked atom will be checked
          # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   the atom which linked with passed atom by passed relation or nil
          def relation_with(atom, relation)
            dept_spec = dept_spec_for(atom)
            awr = dept_spec.relations_of(atom, with_atoms: true).find do |_, r|
              r == relation
            end

            awr && awr.first
          end
        end

      end
    end
  end
end
