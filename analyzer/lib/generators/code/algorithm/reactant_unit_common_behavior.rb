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

          # Iterates other unit which has an atom which also available by passed
          # relation and if is truthy then returns linked atom
          #
          # @param [BaseUnit] other unit for which the atom second will be checked
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   own_atom the atom of current unit for which the relations will be checked
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   other_atom the atom from other unit which uses for comparing original
          #   species
          # @param [Concepts::Bond] relation which existance will be checked
          # @yield [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   the other linked atoms
          # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   the atom which same as last of passed atoms and available by relation, or
          #   nil if linked atom isn't same
          def same_linked_atoms(other, own_atom, other_atom, relation, &block)
            other_dept_spec = other.dept_spec_for(other_atom)
            other_dsa = [other_dept_spec, other_atom]

            each_relations_with(other, own_atom, other_atom, relation) do |(ls, la)|
              linked_dsa = [linked_dept_spec(ls), la]
              props = [linked_dsa, other_dsa].map do |dept_spec, atom|
                atom_properties(dept_spec, atom)
              end

              block[la] if props.permutation(2).any? { |f, s| f.include?(s) }
            end
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
            linked_atom_exp =
              name_of(linked_atom) || atom_from_specie_call(specie, linked_atom)
            "#{name_of(neighbour_atom)} != #{linked_atom_exp}"
          end

        private

          # Gets dependent spec for passed concept spec
          # @param [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec]
          #   spec for which the dependent spec will be gotten
          # @return [Organizers::DependentWrappedSpec] the correct dependent spec
          def linked_dept_spec(spec)
            generator.specie_class(spec.name).spec.clone_with_replace(spec)
          end

          # Gets the code string with getting the target specie from atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom from which the target specie will be gotten
          # @return [String] cpp code string with engine framework method call
          # @override
          def spec_by_role_call(atom)
            super(atom, uniq_specie_for(atom), atom)
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

          # Iterates the spec-atoms linked with passed own atom by passed relation
          # @param [BaseUnit] other unit for which the atom second will be checked
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   own_atom the atom of current unit for which the relations will be checked
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   other_atom the atom from other unit which uses for comparing original
          #   species
          # @param [Concepts::Bond] relation which existance will be checked
          # @yield [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   all available different atoms in relations checker links graph
          # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   the atom which linked with passed atom by passed relation or nil
          def each_relations_with(other, own_atom, other_atom, relation, &block)
            own_concept_spec = concept_spec(own_atom)
            other_concept_spec = other.concept_spec(other_atom)

            own_sa = [own_concept_spec, own_atom]
            other_sa = [other_concept_spec, other_atom]
            same_rels = relations_checker.links[own_sa].select { |_, r| r == relation }
            diff_rels = same_rels.reject { |sa, _| sa == other_sa }
            avail_rels = diff_rels.select do |(s, a), _|
              unit_spec?(s) || other.unit_spec?(s) || name_of(s) || name_of(a)
            end

            avail_rels.map(&:first).each(&block)
          end
        end

      end
    end
  end
end
