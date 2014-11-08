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

        private

          attr_reader :atoms

        end

      end
    end
  end
end
