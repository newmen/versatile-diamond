module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contain logic for building reaction look around algorithm
        class LookAroundFindBuilder < LateralChunksFindBuilder

          # Inits builder by main engine code generator and lateral chunks object
          # @param [EngineCode] generator the major engine code generator
          def initialize(generator)
            super(LookAroundBackbone.new(generator, lateral_chunks))
          end

        private

          # @return [LookAroundPureUnitsFactory]
          def make_pure_factory
            LookAroundPureUnitsFactory.new(dict)
          end

          # @param [Units::ReactionContextProvider] context
          # @return [LookAroundContextUnitsFactory]
          def make_context_factory(context)
            LookAroundContextUnitsFactory.new(dict, pure_factory, context)
          end

          # @oaram [LookAroundContextUnitsFactory] factory
          # @return [Units::LookAroundCreationUnit]
          def make_creator_unit(factory)
            factory.creator
          end
        end

      end
    end
  end
end
