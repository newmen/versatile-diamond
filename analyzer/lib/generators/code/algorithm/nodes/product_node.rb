module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Nodes

        # Contains product and correspond source reactant nodes
        class ProductNode < ChangeNode
          # @return [ReactantNode]
          def source
            other
          end
        end

      end
    end
  end
end
