module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # The unit for combines statements of lateral chunk creation
        class LookAroundCreationUnit < LateralChunksCreationUnit
          include SidepieceAbstractType

        private

          INDEX_NAME = SpeciesReaction::CHUNKS_INDEX_NAME
          CHUNKS_NAME = SpeciesReaction::LATERAL_CHUNKS_NAME

          THIS = Expressions::Core::This[].freeze
          INDEX_TYPE = Expressions::Core::ScalarType['uint'].freeze
          INDEX_VAR = Expressions::Core::Variable[:i, INDEX_TYPE, INDEX_NAME].freeze
          INC_INDEX_EXPR = Expressions::Core::OpRInc[INDEX_VAR].freeze
          CHUNKS_ARR = Expressions::Core::Constant[CHUNKS_NAME].freeze
          CHUNK_VAR =
            CHUNKS_ARR + Expressions::Core::OpSquireBks[INC_INDEX_EXPR].freeze

          # @return [Array]
          def sidepiece_nodes
            uniq_side_nodes
          end

          # @return [String]
          def source_specie_name
            Specie::SIDE_SPECIE_NAME
          end

          # @return [Expressions::Core::Assign]
          def call_create(*exprs)
            value =
              Expressions::Core::Allocate[lateral_reaction_type, THIS, *exprs].freeze
            Expressions::Core::Assign[CHUNK_VAR, value: value].freeze
          end
        end

      end
    end
  end
end
