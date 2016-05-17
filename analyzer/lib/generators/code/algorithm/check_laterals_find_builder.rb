module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contain logic for building reaction check laterals algorithm
        class CheckLateralsFindBuilder < LateralChunksFindBuilder

          # Inits builder
          # @param [EngineCode] generator the major engine code generator
          # @param [LateralChunks] lateral_chunks the target object by which the
          #   algorithm will be generated
          # @param [Specie] target_specie from which the algorithm will be built
          def initialize(generator, lateral_chunks, target_specie)
            backbone =
              CheckLateralsBackbone.new(generator, lateral_chunks, target_specie)
            super(backbone, lateral_chunks)
          end

        private

          # @return [CheckLateralsPureUnitsFactory]
          def make_pure_factory
            CheckLateralsPureUnitsFactory.new(dict)
          end
        end

      end
    end
  end
end
