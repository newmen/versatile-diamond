module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contains several atomic units
        class MultiAtomsUnit < BaseUnit

          def inspect
            "MASU:(#{inspect_atoms_names})"
          end

        private

          # JUST FOR DEBUG INSPECTATIONS
          def inspect_atoms_names
            names = atoms.map do |atom|
              atom_props = Organizers::AtomProperties.new(spec, atom)
              "#{inspect_name_of(atom)}:#{atom_props.to_s}"
            end
            names.join('|')
          end

          # Gets the line with defined anchor atoms for each neighbours operation if
          # them need
          #
          # @return [String] the lines with defined anchor atoms variable
          def define_nbrs_specie_anchors_lines
            if single?
              super
            else
              define_parent_line =
                if atoms.any? { |a| !namer.name_of(a) }
                  define_target_specie_line
                else
                  ''
                end

              define_parent_line + define_nbrs_anchors_line
            end
          end

          # Gets code line with defined anchors atoms for each neighbours operation
          # @return [String] the code line with defined achor atoms variable
          def define_nbrs_anchors_line
            values = atoms.map do |a|
              namer.name_of(a) || atom_from_specie_call(a)
            end

            namer.reassign(Specie::ANCHOR_ATOM_NAME, atoms)
            define_var_line('Atom *', atoms, values)
          end
        end

      end
    end
  end
end
