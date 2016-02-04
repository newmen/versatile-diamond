module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contain logic for create nodes for chunks of lateral reaction and group them
        # by parameters of relations
        class LateralChunksGroupedNodes < BaseGroupedNodes

          # Initializes nodes grouper for chunks of all lateral reactions which are
          # children of passed typical reaction
          #
          # @param [EngineCode] generator the major code generator
          # @param [LateralChunks] lateral_chunks for which the grouped graph will be
          #   built
          def initialize(generator, lateral_chunks)
            super(ReactionNodesFactory.new(generator))
            @lateral_chunks = lateral_chunks

            @_big_graph, @_small_graph, @_action_nodes, @_avail_nodes = nil
          end

          # Gets list of nodes where each node correspond to one target of typical
          # reaction
          #
          # @return [Array] the list of nodes with main targets
          def action_nodes
            @_action_nodes ||= @lateral_chunks.targets.map do |sa|
              avail_nodes.find { |node| node.spec_atom == sa } || get_node(sa)
            end
          end

          # Makes the nodes graph from original links between interacting atoms of
          # chunks
          #
          # @return [Hash] the most comprehensive graph of nodes
          def big_graph
            @_big_graph ||= transform_links(@lateral_chunks.links)
          end

          # Makes the nodes graph from positions of chunks
          # @return [Hash] the small graph of nodes
          def small_graph
            @_small_graph ||= transform_links(@lateral_chunks.clean_links)
          end

        private

          # Gets list of nodes which were created under building final graph
          # @return [Array] the list of existed unique nodes
          def avail_nodes
            @_avail_nodes ||= final_graph.flat_map(&:first).uniq
          end

          # Detects relation between passed nodes
          # @param [Array] nodes the array with two nodes between which the relation
          #   will be detected
          # @return [Concepts::Bond] the relation between atoms from passed nodes
          def relation_between(*nodes)
            @lateral_chunks.relation_between(*nodes.map(&:spec_atom))
          end
        end

      end
    end
  end
end
