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
          # @return [TargetNode] unique target node of look around algorithm
          def target_node(node)
            @target_nodes[node] ||= TargetNode.new(@lateral_chunks, node)
          end

          # @param [ReactantNode] node
          # @return [SidepieceNode]
          def sidepiece_node(node)
            @sidepiece_nodes[node] ||=
              SidepieceNode.new(@lateral_chunks, node, identity_of(node))
          end

          # @param [ReactantNode] node
          # @return [OthersideNode]
          def otherside_node(node)
            @otherside_nodes[node] ||= OthersideNode.new(@lateral_chunks, node)
          end

        private

          # @param [ReactantNode] node
          # @return [ReactantNode]
          def identity_of(node)
            san = @identities.find { |sa, _| same_key?(node, sa) }
            san ? san.last : append_identity!(node)
          end

          # @param [ReactantNode] node
          # @return [ReactantNode]
          def append_identity!(node)
            identity = @lateral_chunks.side_keys.find { |sa| same_key?(node, sa) }
            if identity
              @identities[identity] = node
            else
              raise ArgumentError, 'Node is not a sidepiece'
            end
          end

          # @param [ReactantNode] node
          # @param [Array] identity_spec_atom
          # @return [Boolean]
          def same_key?(node, identity_spec_atom)
            if node.spec_atom.first == identity_spec_atom.first
              node.spec_atom.last == identity_spec_atom.last
            else
              same_sa?(node.spec_atom, identity_spec_atom)
            end
          end
        end

      end
    end
  end
end
