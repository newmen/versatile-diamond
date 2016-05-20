module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates nodes for lateral algorithm graphs building
        class LateralNodesFactory
          include Mcs::SpecsAtomsComparator

          # Initizalize nodes factory by lateral chunks object
          # @param [LateralChunks] lateral_chunks
          def initialize(lateral_chunks)
            @lateral_chunks = lateral_chunks

            @target_nodes = {}
            @sidepiece_nodes = {}
            @otherside_nodes = {}

            @identities = {}
          end

          # @param [ReactantNode] node
          def target_node(node)
            @target_nodes[node] ||= TargetNode.new(@lateral_chunks, node)
          end

          # @param [ReactantNode] node
          def sidepiece_node(node)
            @sidepiece_nodes[node] ||=
              SidepieceNode.new(@lateral_chunks, node, identity_of(node))
          end

          # @param [ReactantNode] node
          def otherside_node(node)
            @otherside_nodes[node] ||= OthersideNode.new(@lateral_chunks, node)
          end

        private

          # @param [ReactantNode] node
          # @return [ReactantNode]
          def identity_of(node)
            san = @identities.find { |sa, _| same_sa?(sa, node.spec_atom) }
            san ? san.last : append_identity!(node)
          end

          # @param [ReactantNode] node
          # @return [ReactantNode]
          def append_identity!(node)
            identity =
              @lateral_chunks.side_keys.find { |sa| same_sa?(sa, node.spec_atom) }
            if identity
              @identities[identity] = node
            else
              raise ArgumentError, 'Node is not a sidepiece'
            end
          end
        end

      end
    end
  end
end
