module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Provides logic for checking relations between atoms which avail on other
        # side
        module OtherSideRelationsCppExpression
        private

          # Appends other unit
          # @param [BaseUnit] other unit which will be appended
          # @return [Array] the appending reault
          def append_self_other(other)
            units_with_atoms = append_other(other)
            units_with_atoms + units_with_atoms.map(&:last).combination(2).to_a
          end

          # Makes conditions block which will be placed into eachNeighbour lambda call
          # @param [String] condition_str the original condition string which will be
          #    extended
          # @param [BaseUnit] other unit which will be checked in conditions
          # @yield should return cpp code string of conditions body
          # @return [String] the string with cpp code
          # @override
          def each_nbrs_condition(condition_str, other, &block)
            units_with_atoms = append_self_other(other)
            acnd_str = append_check_bond_conditions(condition_str, units_with_atoms)
            code_condition(acnd_str) do
              same_atoms_condition(units_with_atoms, &block)
            end
          end

          # Gets condition where checks that some atoms of current unit is not same as
          # atoms in other unit
          #
          # @param [Array] units_with_atoms is the pairs of atoms between which the
          #   bond existatnce will be checked
          # @yield should returns the internal code for body of condition
          # @return [String] cpp code string with condition if it need
          def same_atoms_condition(units_with_atoms, &block)
            quads = reduce_if_relation(units_with_atoms) do |acc, usp, asp, rel|
              cur, oth = usp
              linked_atom = cur.same_linked_atom(oth, *asp, rel)
              acc << [cur, linked_atom, *asp] if linked_atom
            end

            if quads.empty?
              block.call
            else
              uswas = quads.map { |unit, _, atom, _| [unit, atom] }
              define_str = define_unknown_species(uswas) # assing names to species
              conditions = quads.map do |u, l, t, n|
                u.not_own_atom_condition(u.uniq_specie_for(t), l, n)
              end

              define_str + code_condition(conditions.join(' && '), &block)
            end
          end
        end

      end
    end
  end
end
