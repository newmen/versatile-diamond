module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code
      module Algorithm

        # Cleans the chunks grouped nodes graph from not significant relations
        # @abstract
        class LateralChunksBackbone
          include Modules::GraphDupper
          extend Forwardable

          # Initializes backbone by lateral chunks object
          # @param [EngineCode] generator the major engine code generator
          # @param [LateralChunks] lateral_chunks the target object for which the graph
          #   will be built
          def initialize(generator, lateral_chunks)
            @lateral_chunks = lateral_chunks
            @lateral_nodes_factory = LateralNodesFactory.new(lateral_chunks)
            @grouped_nodes_graph =
              LateralChunksGroupedNodes.new(generator, lateral_chunks)

            @_action_nodes, @_final_graph, @_big_graph = nil
            @_target_key_nodes, @_grouped_ratio = nil
          end

          # Cleans grouped graph from unsignificant relations
          # @return [Hash] the grouped graph with relations only from target nodes
          # TODO: must be private!
          def final_graph
            @_final_graph ||=
              @grouped_nodes_graph.final_graph.select { |key, _| all_final_keys?(key) }
          end

          # Gets list of nodes from which find begins
          # @return [Array] the array of anchor nodes
          def action_nodes
            @_action_nodes ||=
              @grouped_nodes_graph.action_nodes(action_keys).map(&method(:target_node))
          end

          # Gets entry nodes for generating algorithm
          # @return [Array] the array of entry nodes
          def entry_nodes
            grouped_keys.sort { |a, b| b <=> a }
          end

          # Gets ordered graph from passed nodes where each side node is replaced
          # @param [Array] nodes
          # @return [Array]
          def ordered_graph_from(nodes)
            is_dk = grouped_ratio.any? { |key, _| key.equal?(nodes) }
            grouped_ratio.select do |key, _|
              (is_dk && key.equal?(nodes)) ||
                (!is_dk && key.all?(&nodes.public_method(:include?)))
            end
          end

          # Gets big grouped graph with reverse relations
          # @return [Hash]
          def big_graph
            @_big_graph ||=
              dup_graph(@grouped_nodes_graph.overall_graph, &method(:lateral_node))
          end

        private

          attr_reader :lateral_chunks, :lateral_nodes_factory
          def_delegator :lateral_nodes_factory, :otherside_node

          # @param [Array] nodes
          # @return [Boolean]
          def all_final_keys?(nodes)
            nodes.all?(&method(:final_key?))
          end

          # @param [Nodes::ReactantNode] node
          # @return [Boolean]
          def final_key?(node)
            check_spec_of(node, target_predicate_name)
          end

          # @param [ReactantNode] node
          # @return [LateralNode]
          def lateral_node(node)
            final_key?(node) ? target_node(node) : otherside_node(node)
          end

          # @param [Array] nodes
          # @return [Array]
          def replace_nodes(nodes)
            nodes.map(&method(:lateral_node))
          end

          # @return [Array]
          def mono_lateral_graph
            final_graph.flat_map do |key, rels|
              rels.map do |nbrs, rels|
                # dup is significant here!
                [replace_nodes(key).dup, [[replace_nodes(nbrs), rels]]]
              end
            end
          end

          # @return [Array]
          def ordered_mono_graph
            mono_lateral_graph.sort_by do |key, rps|
              indexes = key.map { |n| action_nodes.index(n) || action_nodes.size }
              rels = rps.flat_map { |nbrs, _| relations_between(key, nbrs) }.sort
              [indexes, rels]
            end
          end

          # @return [Array]
          def grouped_ratio
            @_grouped_ratio ||=
              ordered_mono_graph.groups(&method(:key_group_by_slice)).map do |group|
                [group.first.first, group.map(&:last).reduce(:+)]
              end
          end

          # @return [Array]
          def grouped_keys
            group_by_reactions(grouped_ratio).map do |group|
              group.one? ? group.first.first : group.flat_map(&:first)
            end
          end

          # @param [ReactantNode] node
          # @param [Symbol] method_name
          # @return [Boolean]
          def check_spec_of(node, method_name)
            lateral_chunks.public_send(method_name, node.spec.spec)
          end

          # @param [Array] key
          # @param [Array] nbrs
          # @return [Array]
          def relations_between(key, nbrs)
            key.flat_map { |node| nbrs.map(&relation_between_proc(node)) }.compact
          end

          # @param [Array] node
          # @return [Proc]
          def relation_between_proc(node)
            -> n { lateral_chunks.relation_between(node.spec_atom, n.spec_atom) }
          end
        end

      end
    end
  end
end
