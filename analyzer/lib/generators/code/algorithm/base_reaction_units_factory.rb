module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code
      module Algorithm

        # Creates reaction algorithm units
        # @abstract
        class BaseReactionUnitsFactory < BaseUnitsFactory

          # Initializes reaction algorithm units factory
          # @param [EngineCode] generator the major code generator
          def initialize(generator)
            super(generator)
            create_namer! # just create internal names accumulator
          end
        end

      end
    end
  end
end
