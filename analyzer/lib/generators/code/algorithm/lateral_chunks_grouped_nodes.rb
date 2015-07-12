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
          #   builded
          def initialize(generator, lateral_chunks)
            super(ReactionNodesFactory.new(generator))
            @lateral_chunks = lateral_chunks

            @_big_graph, @_small_graph = nil
          end

          # Makes the nodes graph from original links between interacting atoms of
          # chunks
          #
          # @return [Hash] the most comprehensive graph of nodes
          def big_graph
            @_big_graph ||= transform_links(@lateral_chunks.links)
          end

        private

          # Makes the nodes graph from positions of chunks
          # @return [Hash] the small graph of nodes
          def small_graph
            @_small_graph ||= transform_links(@lateral_chunks.clean_links)
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
