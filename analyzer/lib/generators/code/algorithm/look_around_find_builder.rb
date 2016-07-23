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
            backbone = LookAroundBackbone.new(generator, lateral_chunks)
            super(backbone, lateral_chunks.reaction)
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

          # @return [Expressions::Core::Statement]
          # @override
          def complete_algorithm
            action_unit.define_scope!
            super
          end
        end

      end
    end
  end
end
