module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code
      module Algorithm

        # Cleans the chunks grouped nodes graph from not significant relations
        # @abstract
        class LateralChunksBackbone
          include Modules::GraphDupper
          include BackboneExtender
          include NodesCollector
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

            @slices_cache = {}
            @_action_nodes, @_final_graph, @_big_graph, @_big_ungrouped_graph = nil
          end

          # Cleans grouped graph from unsignificant relations
          # @return [Hash] the grouped graph with relations only from target nodes
          # TODO: must be private!
          def final_graph
            @_final_graph ||= cut_and_extend_to_anchors(complete_grouped_graph)
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
            recombined_graph = grouped_ratio(final_graph)
            is_dk = recombined_graph.any? { |key, _| key.equal?(nodes) }
            recombined_graph.select do |key, _|
              !is_dk || (is_dk && key.equal?(nodes))
            end
          end

          # Gets big grouped graph with reverse relations
          # @return [Hash]
          def big_graph
            @_big_graph ||= dup_graph(big_ungrouped_graph, &method(:lateral_node))
          end

        private

          attr_reader :lateral_chunks, :lateral_nodes_factory
          def_delegator :lateral_nodes_factory, :otherside_node
          def_delegator :@grouped_nodes_graph, :complete_grouped_graph
          def_delegators :@grouped_nodes_graph, :overall_graph, :relation_between

          # @return [Hash]
          def big_ungrouped_graph
            @_big_ungrouped_graph ||=
              overall_graph.each_with_object({}) do |(node, rels), acc|
                unless drop_action?(node)
                  clean_rels = rels.reject { |n, _| drop_action?(n) }
                  acc[node] = clean_rels unless clean_rels.empty?
                end
              end
          end

          # @param [Nodes::ReactantNode] node
          # @return [Boolean]
          def drop_action?(node)
            original_actions = action_nodes.map(&:original)
            !original_actions.include?(node) &&
              original_actions.any? { |n| n.uniq_specie == node.uniq_specie }
          end

          # @param [Array] nodes
          # @return [Boolean]
          def own_key?(nodes)
            nodes.all?(&method(:target_key?))
          end

          # @param [Nodes::ReactantNode] node
          # @return [Boolean]
          def target_key?(node)
            check_spec_of(node, target_predicate_name)
          end

          # @param [ReactantNode] node
          # @return [LateralNode]
          def lateral_node(node)
            target_key?(node) ? target_node(node) : otherside_node(node)
          end

          # @param [Array] nodes
          # @return [Array]
          def replace_nodes(nodes)
            nodes.map(&method(:lateral_node))
          end

          # @param [Hash] graph
          # @return [Array]
          def mono_graph(graph)
            graph.flat_map do |key, rels|
              rels.map do |nbrs, rp|
                @slices_cache[[key, nbrs, rp]] ||=
                  # dup is significant here!
                  [replace_nodes(key).dup, [[replace_nodes(nbrs), rp]]]
              end
            end
          end

          # @param [Hash] graph
          # @return [Array]
          def reorder_graph(graph)
            nz = graph.size
            max_n = nz ** 2
            flatten_graph = mono_graph(graph)
            back_mirror = invert_nbrs(flatten_graph)

            flatten_graph.sort_by do |key, rps|
              indexes = key.map do |n|
                index = action_nodes.index(n)
                if index
                  index * nz
                else
                  back_index = action_nodes.index(back_mirror[n])
                  back_index ? back_index * nz + 1 : max_n
                end
              end

              rels = rps.flat_map { |nbrs, _| relations_between(key, nbrs) }.sort
              [indexes, rels]
            end
          end

          # @param [Array] graph
          # @return [Hash]
          def invert_nbrs(graph)
            graph.each_with_object({}) do |(key, rps), acc|
              key.each do |node|
                rps.flat_map(&:first).each do |n, _|
                  # TODO: there can be many to many in generic way
                  acc[n] = node if relation_between(node, n)
                end
              end
            end
          end

          # @param [Hash] graph
          # @return [Array]
          def grouped_ratio(graph)
            reorder_graph(graph).groups(&method(:key_group_by_slice)).map do |group|
              [group.first.first, group.map(&:last).reduce(:+)]
            end
          end

          # @return [Array]
          def grouped_keys
            cutten_final_graph = cut_own_branches(complete_grouped_graph)
            group_by_reactions(grouped_ratio(cutten_final_graph)).map do |group|
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
            -> n { relation_between(node, n) }
          end
        end

      end
    end
  end
end
