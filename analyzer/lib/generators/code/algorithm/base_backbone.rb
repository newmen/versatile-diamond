module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Provides base logic for backbone instance
        # @abstract
        class BaseBackbone
          extend Forwardable

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
            ordered_graph = build_sequence_from(nodes)
            maximals = ordered_graph.select do |kns, rels|
              kns.all?(&:lattice) && kns.size > 1 && !rels.empty? &&
                rels.all? { |vns, _| vns.size == kns.size } &&
                kns.all? { |kn| kn.relations_limits[rels.first.last] == rels.size }
            end

            maximals.each do |mx|
              index = ordered_graph.index(mx)
              ordered_graph.delete_at(index)
              relation = mx.last.first.last
              [mx.first, *mx.last.map(&:first)].transpose.each do |k, *vs|
                ordered_graph.insert(index, [[k], [[vs, relation]]])
              end
            end

            ordered_graph
          end

        private

          attr_reader :grouped_nodes_graph
          def_delegator :grouped_nodes_graph, :final_graph

          # Builds sequence of kv pairs from graph for find algorithm walking
          # @param [Array] nodes from wich reverse relations of final graph will
          #   be rejected
          # @param [Hash] directed graph without loops
          # @option [Hash] :init_graph the graph which uses as initial value for
          #   internal purging graph
          # @option [Set] :visited_key_nodes the set of visited nodes of internal
          #   purging graph
          # @return [Array] the ordered list that contains the ordered relations from
          #   final graph
          def build_sequence_from(nodes, init_graph: nil, visited_key_nodes: Set.new)
            result = []
            directed_graph = init_graph || final_graph
            nodes_queue = nodes.dup

            until nodes_queue.empty?
              node = nodes_queue.shift
              node_to_nodes[node].each do |next_nodes|
                next_nodes_set = next_nodes.to_set
                next if visited_key_nodes.include?(next_nodes_set)

                visited_key_nodes << next_nodes_set
                rels = directed_graph[next_nodes]
                next unless rels

                result << [next_nodes, sort_rels_by_limits_of(next_nodes, rels)]
                next if rels.empty?

                directed_graph = without_reverse(directed_graph, next_nodes)
                nodes_queue += rels.flat_map(&:first)
              end
            end

            connected_nodes_from(directed_graph).each do |ns|
              next if visited_key_nodes.include?(ns.to_set)
              result += build_sequence_from(ns,
                init_graph: directed_graph, visited_key_nodes: visited_key_nodes)
            end

            unconnected_nodes_from(directed_graph).each do |ns|
              result << [ns, []] unless visited_key_nodes.include?(ns.to_set)
            end

            result
          end

          # Makes mirror from each node to correspond nodes of grouped graph
          # @return [Hash] the mirror from each node to grouped graph nodes
          def node_to_nodes
            @_node_to_nodes ||=
              collect_nodes(final_graph).each_with_object({}) do |nodes, result|
                nodes.each do |node|
                  result[node] ||= Set.new
                  result[node] << nodes
                end
              end
          end

          # Collects all nodes from final graph
          # @return [Array] the sorted array of nodes lists
          def collect_nodes(graph)
            lists = graph.each_with_object([]) do |(nodes, rels), acc|
              acc << nodes
              rels.each { |ns, _| acc << ns }
            end
            lists.uniq.sort_by(&:size)
          end

          # Removes reverse relations to passed nodes
          # @param [Hash] graph from which reverse relations will be excepted
          # @param [Array] nodes of graph to which the reverse relations will be
          #   excepted
          # @return [Hash] the graph without reverse relations
          def without_reverse(graph, nodes)
            reject_proc = proc { |ns| nodes.include?(ns) }

            # except multi reverse relations
            other_side_nodes = graph[nodes].map(&:first)
            without_full_others = except_relations(graph, reject_proc) do |ns|
              other_side_nodes.include?(ns)
            end

            # except single reverse relations
            single_other_nodes = other_side_nodes.flatten.uniq
            except_relations(without_full_others, reject_proc) do |ns|
              ns.size == 1 && single_other_nodes.include?(ns.first)
            end
          end

          # Removes relations from passed graph by two conditions
          # @param [Proc] reject_proc the function which reject neighbours nodes
          # @yield [Array] by it condition checks that erasing should to be
          # @return [Hash] the graph without erased relations
          def except_relations(graph, reject_proc, &condition_proc)
            graph.each_with_object({}) do |(nodes, rels), result|
              if condition_proc[nodes]
                new_rels = rels.reduce([]) do |acc, (nss, r)|
                  new_nss = nss.reject(&reject_proc)
                  new_nss.empty? ? acc : acc << [new_nss, r]
                end

                result[nodes] = new_rels unless new_rels.empty?
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
