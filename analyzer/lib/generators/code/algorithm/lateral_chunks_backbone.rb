module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Cleans the chunks grouped nodes graph from not significant relations
        # @abstract
        class LateralChunksBackbone
          extend Forwardable

          def_delegator :grouped_nodes_graph, :big_graph

          # Initializes backbone by lateral chunks object
          # @param [EngineCode] generator the major engine code generator
          # @param [LateralChunks] lateral_chunks the target object for which the graph
          #   will be built
          def initialize(generator, lateral_chunks)
            @lateral_chunks = lateral_chunks
            @grouped_nodes_graph =
              LateralChunksGroupedNodes.new(generator, lateral_chunks)

            @_final_graph = nil
          end

          # Gets entry nodes for generating algorithm
          # @return [Array] the array of entry nodes
          def entry_nodes
            grouped_keys.map { |group| group.reduce(:+).sort }.sort
          end

          # Cleans grouped graph from unsignificant relations
          # @return [Hash] the grouped graph with relations only from target nodes
          # TODO: must be private!
          def final_graph
            @_final_graph ||= make_final_graph
          end

          # Gets ordered graph from passed nodes where each side node is replaced
          # @param [Array] nodes
          # @return [Array]
          def ordered_graph_from(nodes)
            raw_directed_graph_from(nodes).map do |key, rels|
              [key, rels.map { |ns, r| [ns.map(&method(:side_node)), r] }]
            end
          end

        private

          attr_reader :lateral_chunks, :grouped_nodes_graph

          # Gets grouped graph
          # @return [LateralChunksGroupedNodes]
          def grouped_graph
            grouped_nodes_graph.final_graph
          end

          # Makes small directed graph for check sidepiece species
          # @param [Array] nodes for which the graph will returned
          # @return [Array] the ordered list that contains the relations from final
          #   graph
          def raw_directed_graph_from(nodes)
            grouped_slices(nodes).reduce([]) do |acc, group|
              keys = group.flat_map(&:first).uniq
              lists_are_identical?(keys, nodes) ? acc + group : acc
            end
          end

          # @param [Array] nodes
          # @return
          def slices_with(nodes)
            final_graph.select { |k, _| k.all?(&nodes.public_method(:include?)) }.to_a
          end

          # @param [Array] nodes
          # @return [LateralReaction] single lateral reaction
          def reaction_with(node)
            lateral_chunks.select_reaction(node.spec_atom)
          end

          # @param [Nodes::ReactantNode] node
          # @return [Nodes::SideNode]
          def side_node(node)
            Nodes::SideNode.new(node)
          end
        end

      end
    end
  end
end
