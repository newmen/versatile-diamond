module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates reaction find algorithm units
        # @abstract
        class BaseUnitsFactory

          # Initializes reaction find algorithm units factory
          # @param [EngineCode] generator the major code generator
          def initialize(generator)
            @generator = generator
            @namer = nil
          end

          # Provokes namer to save next checkpoint
          def remember_names!
            namer.checkpoint!
          end

          # Provokes namer to rollback names from last checkpoint
          def restore_names!
            namer.rollback!
          end

        private

          attr_reader :generator, :namer

          # Resets the internal variables which accumulates data when algorithm code
          # builds
          def create_namer!
            @namer = NameRemember.new
          end

          # Gets the list of default arguments which uses when each new unit creates
          # @return [Array] the array of default arguments
          def default_args
            [generator, namer]
          end
        end

      end
    end
  end
end
