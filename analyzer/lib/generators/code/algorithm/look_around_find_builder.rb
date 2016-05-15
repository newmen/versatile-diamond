module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contain logic for building reaction look around algorithm
        class LookAroundFindBuilder < LateralChunksFindBuilder

          # Inits builder by main engine code generator and lateral chunks object
          # @param [EngineCode] generator the major engine code generator
          # @param [LateralChunks] lateral_chunks the target object by which the
          #   algorithm will be generated
          def initialize(generator, lateral_chunks)
            super(LookAroundBackbone.new(generator, lateral_chunks), lateral_chunks)
          end

        private

          # @return [LookAroundPureUnitsFactory]
          def make_pure_factory
            LookAroundPureUnitsFactory.new(dict)
          end
        end

      end
    end
  end
end
