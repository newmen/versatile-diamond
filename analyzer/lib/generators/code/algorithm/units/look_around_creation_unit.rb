module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # The unit for combines statements of lateral chunk creation
        class LookAroundCreationUnit < LateralChunksCreationUnit
          include SidepieceAbstractType

        private

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
            this = dict.var_of(:this)
            chunks_arr = dict.var_of(:chunks)
            value = Expressions::Core::Allocate[lateral_reaction_type, this, *exprs]
            Expressions::Core::Assign[chunks_arr, value: value].freeze
          end
        end

      end
    end
  end
end
