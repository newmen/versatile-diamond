module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Nodes

        # Represents node which is wrapped the unique side node but behalves like not
        # unique node
        class SidepieceNode < LateralNode
          # @param [LateralChunks] lateral_chunks
          # @param [ReactantNode] uniq_side_node
          # @param [ReactantNode] identity_node
          def initialize(lateral_chunks, uniq_side_node, identity_node)
            super(lateral_chunks, identity_node)
            @uniq_side_node = uniq_side_node
          end

          # @return [Array]
          def spec_atom
            @uniq_side_node.spec_atom
          end
        end

      end
    end
  end
end
