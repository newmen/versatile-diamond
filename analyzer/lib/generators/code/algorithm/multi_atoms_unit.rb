module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contains several atomic units
        class MultiAtomsUnit < BaseUnit

          # Also remembers the list of atomic units
          # @param [Array] args of #super method
          # @param [Array] atoms which will be used for code generation
          def initialize(*args, atoms)
            super(*args)
            @atoms = atoms
          end

          def inspect
            "MASU:(#{inspect_atoms_names})"
          end

        private

          attr_reader :atoms

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
          def define_nbrs_anchors_lines
            if single?
              super
            else
              define_parent_line =
                if atoms.any? { |a| !namer.name_of(a) }
                  define_target_specie_line
                else
                  ''
                end

              values = atoms.map do |a|
                namer.name_of(a) || atom_from_specie_call(a)
              end

              namer.reassign(Specie::ANCHOR_ATOM_NAME, atoms)
              define_parent_line + define_var_line('Atom *', atoms, values)
            end
          end
        end

      end
    end
  end
end
