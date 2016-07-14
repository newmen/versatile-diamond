module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Provides base logic for backbone instance
        # @abstract
        class BaseBackbone
          include Modules::ListsComparer
          include NodesCollector
          extend Forwardable

          def_delegator :grouped_nodes_graph, :big_graph

          # Initializes backbone by grouped nodes graph
          # @param [Hash] group
          def initialize(grouped_nodes_graph)
            @grouped_nodes_graph = grouped_nodes_graph

            @_node_to_nodes = nil
          end

          # Makes directed graph for walking when find algorithm builds
          # @param [Array] nodes from wich reverse relations of final graph will
          #   be rejected
          # @return [Array] the ordered list that contains the ordered relations from
          #   final graph
          def ordered_graph_from(nodes)
            reorder_by_maximals(build_sequence_from(final_graph, nodes, Set.new))
          end

        private

          attr_reader :grouped_nodes_graph
          def_delegator :grouped_nodes_graph, :final_graph

          # Builds sequence of kv pairs from graph for find algorithm walking
          # @param [Hash] graph by which the sequence will be combined
          # @param [Array] nodes from which the sequence will built
          # @param [Set] visited nodes
          # @return [Array] the ordered list that contains the ordered relations from
          #   passed directed graph
          def build_sequence_from(graph, nodes, visited)
            result = []
            nodes_queue = nodes.dup

            until nodes_queue.empty?
              node = nodes_queue.shift
              groups = node_to_nodes[node]
              ogs = groups.sort_by { |ns| lists_are_identical?(nodes, ns) ? -1 : 0 }
              ogs.each do |next_nodes|
                next_nodes_set = next_nodes.to_set
                next if visited.include?(next_nodes_set)

                visited << next_nodes_set
                rels = graph[next_nodes]
                next unless rels

                result << [next_nodes, sort_rels_by_limits_of(next_nodes, rels)]
                next if rels.empty?

                graph = without_reverse(graph, next_nodes)
                nodes_queue += rels.flat_map(&:first)
              end
            end

            result +
              build_next_sequence(graph, visited) +
              build_unconnected_sequence(graph, visited)
          end

          # Builds the next part of sequence of find algorithm steps by nodes which
          # are relates to already added nodes
          #
          # @param [Hash] graph the graph which uses for receive next nodes
          # @param [Set] visited nodes
          # @return [Array] the sequence of nodes which were not added under building
          #   main sequence of find algorithm steps
          def build_next_sequence(graph, visited)
            connected_nodes_from(graph).reduce([]) do |acc, nodes|
              next acc if visited.include?(nodes.to_set)
              acc + build_sequence_from(graph, nodes, visited)
            end
          end

          # Builds the last part of nodes sequence for find algorithm steps
          # @param [Hash] graph the graph which uses for receive next nodes
          # @param [Set] visited nodes
          # @return [Array] the sequence of nodes which haven't any relations and not
          #   added under building the main sequence of find algorithm steps
          def build_unconnected_sequence(graph, visited)
            unconnected_nodes_from(graph).each_with_object([]) do |nodes, acc|
              acc << [nodes, []] unless visited.include?(nodes.to_set)
            end
          end

          # Reorders passed graph when for some key nodes of it the
          # maximal relations condition is met
          #
          # @param [Hash] ordered_graph which will trying to reorder
          # @return [Hash] original passed graph or reordered graph
          def reorder_by_maximals(ordered_graph)
            maximals(ordered_graph).each_with_object(ordered_graph) do |mx, acc|
              index = acc.index(mx)
              acc.delete_at(index)
              relation = mx.last.first.last
              [mx.first, *mx.last.map(&:first)].transpose.each do |k, *vs|
                acc.insert(index, [[k], [[vs, relation]]])
              end
            end
          end

          # Collects the nodes which have maximal number of relations
          # @param [Array] ordered_graph the flatten graph from which the components
          #   with maximal number of relations will extracted
          # @return [Array] the flatten graph with nodes which have maximal number of
          #   relations
          def maximals(ordered_graph)
            ordered_graph.select { |nodes, rels| maximal_rels?(nodes, rels) }
          end

          # Checks that passed nodes can be selected for maximal relations graph
          # @param [Array] nodes which properties and relations checks
          # @param [Array] rels the relations of passed nodes
          # @return [Boolean] is nodes should be reordering much optimal or not
          def maximal_rels?(nodes, rels)
            nodes.all?(&:lattice) && nodes.size > 1 && !rels.empty? &&
              rels.all? { |nbrs, _| nbrs.size == nodes.size } &&
              nodes.all? { |nd| nd.relations_limits[rels.first.last] == rels.size }
          end

          # Makes mirror from each node to correspond nodes of grouped graph
          # @return [Hash] the mirror from each node to grouped graph nodes
          def node_to_nodes
            return @_node_to_nodes if @_node_to_nodes

            result =
              collect_nodes(final_graph).each_with_object({}) do |nodes, result|
                nodes.each do |node|
                  result[node] ||= Set.new
                  result[node] << nodes
                end
              end

            cmp_proc = method(:cmp_nodes_lists)
            @_node_to_nodes =
              result.map { |n, nss| [n, nss.to_a.sort(&cmp_proc)] }.to_h
          end

          # @param [Array] ns1 list 1
          # @param [Array] ns2 list 2
          # @return [Integer] the result of comparation
          def cmp_nodes_lists(ns1, ns2)
            cmp = (ns1.size <=> ns2.size)
            cmp == 0 ? ns1 <=> ns2 : cmp
          end

          # Removes reverse relations to passed nodes
          # @param [Hash] graph from which reverse relations will be excepted
          # @param [Array] nodes the reverse relations to which will be excepted
          # @param [Array] neighbours the reverse relations from which will be excepted
          # @return [Hash] the graph without reverse relations
          def without_reverse(graph, nodes, neighbours = nil)
            neighbours ||= graph[nodes].map(&:first)
            clean_graph = except_multi_reverse_relations(graph, nodes, neighbours)
            except_single_reverse_relations(clean_graph, nodes, neighbours)
          end

          # Removes multi reverse relations to passed nodes
          # @param [Hash] graph from which reverse relations will be excepted
          # @param [Array] nodes the reverse relations to which will be excepted
          # @param [Array] neighbours the reverse relations from which will be excepted
          # @return [Hash] the graph without multi reverse relations
          def except_multi_reverse_relations(graph, nodes, neighbours)
            except_relations(graph, nodes, &include_proc(neighbours))
          end

          # @param [Array] nodes_lists
          # @return [Proc]
          def include_proc(nodes_lists)
            -> key do
              nodes_lists.any? { |ns| lists_are_identical?(key, ns) }
            end
          end

          # Removes single reverse relations to passed nodes
          # @param [Hash] graph from which reverse relations will be excepted
          # @param [Array] nodes the reverse relations to which will be excepted
          # @param [Array] neighbours the reverse relations from which will be excepted
          # @return [Hash] the graph without single reverse relations
          def except_single_reverse_relations(graph, nodes, neighbours)
            single_neighbours = neighbours.flatten.uniq
            except_relations(graph, nodes) do |ns|
              ns.one? && single_neighbours.include?(ns.first)
            end
          end

          # Removes relations from passed graph by two conditions
          # @param [Proc] reject_lambda the function which reject neighbours nodes
          # @yield [Array] it condition checks that erasing should to be
          # @return [Hash] the graph without erased relations
          def except_relations(graph, target_nodes, &block)
            graph.each_with_object({}) do |(nodes, rels), result|
              if block[nodes]
                new_rels = rels.each_with_object([]) do |(nbrs, r), acc|
                  new_nbrs = nbrs.reject(&target_nodes.public_method(:include?))
                  acc << [new_nbrs, r] unless new_nbrs.empty?
                end

                result[nodes] = new_rels if !new_rels.empty? || rels.empty?
              else
                result[nodes] = rels
              end
            end
          end

          # Sorts passed relations list by relation limits of passed nodes
          # @param [Array] nodes from which relation limits will be gotten
          # @param [Array] rels the relations list of passed nodes
          # @return [Array] the sorted list of relations
          def sort_rels_by_limits_of(nodes, rels)
            rels.sort_by do |nbrs, rel_params|
              rel_ratio = nbrs.size / nodes.size
              max_limit = nodes.map { |n| n.relations_limits[rel_params] }.max
              max_limit == rel_ratio ? max_limit : 1000 + max_limit - rel_ratio
            end
          end

          # Gets the list of nodes which with relations list from passed graph
          # @param [Hash] graph in which connected nodes will be found
          # @return [Array] the list of connected nodes
          def connected_nodes_from(graph)
            graph.reject { |_, rels| rels.empty? }.map(&:first)
          end

          # Gets the list of unconnected nodes from passed graph
          # @param [Hash] graph in which unconnected nodes will be found
          # @return [Array] the list of unconnected nodes
          def unconnected_nodes_from(graph)
            graph.select { |_, rels| rels.empty? }.map(&:first)
          end
        end

      end
    end
  end
end
