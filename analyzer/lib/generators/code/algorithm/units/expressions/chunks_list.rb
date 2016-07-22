module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        # Describes chunks aggregator array variable
        class ChunksList < Core::Variable
          # @return [Boolean]
          # @override
          def item?
            false
          end
        end

      end
    end
  end
end
