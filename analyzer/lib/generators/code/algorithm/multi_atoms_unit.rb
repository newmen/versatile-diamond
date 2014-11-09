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
            "MASU:(#{inspect_atoms_names.join('|')})"
          end

        private

          attr_reader :atoms

          # JUST FOR DEBUG INSPECTATIONS
          def inspect_atoms_names
            atoms.map do |atom|
              atom_props = Organizers::AtomProperties.new(spec, atom)
              "#{inspect_name_of(atom)}:#{atom_props.to_s}"
            end
          end
        end

      end
    end
  end
end
