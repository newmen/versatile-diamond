module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contains several atomic units
        class MultiAtomsUnit < SimpleUnit

          def inspect
            "MASU:(#{inspect_atoms_names})"
          end

        private

          # JUST FOR DEBUG INSPECTATIONS
          def inspect_atoms_names
            names = atoms.map do |atom|
              atom_props = atom_properties(original_spec, atom)
              "#{inspect_name_of(atom)}:#{atom_props}"
            end
            names.join('|')
          end

          # Gets the line with defined anchor atoms for each neighbours operation if
          # them need
          #
          # @return [String] the lines with defined anchor atoms variable
          # @override
          def define_nbrs_specie_anchors_lines
            if single?
              super
            else
              define_parent_line = all_defined?(atoms) ? '' : define_target_specie_line
              define_parent_line + define_nbrs_anchors_line
            end
          end

          # Gets code line with defined anchors atoms for each neighbours operation
          # @return [String] the code line with defined achor atoms variable
          def define_nbrs_anchors_line
            if (atoms.size == 1 && name_of(atoms.first)) || namer.full_array?(atoms)
              ''
            else
              values = atom_values # collect before reassign
              namer.reassign(Specie::ANCHOR_ATOM_NAME, atoms)
              define_var_line('Atom *', atoms, values)
            end
          end

          # Collects the names of atom variables or calls them from own specie
          # @return [Array] the list of atom names or specie calls
          def atom_values
            names_or(atoms, &method(:atom_from_own_specie_call))
          end
        end

      end
    end
  end
end
