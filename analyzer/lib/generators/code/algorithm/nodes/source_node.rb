module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Nodes

        # Contains source and correspond product reactant nodes
        class SourceNode < ChangeNode
          # @return [ReactantNode]
          def product
            other
          end
        end

      end
    end
  end
end
