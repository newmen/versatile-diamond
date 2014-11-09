module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Cleans the specie grouped nodes graph from not significant relations and
        # gets the ordered graph by which the find specie algorithm will be builded
        class SpecieBackbone
          include Modules::ListsComparer
          extend Forwardable

          # Initializes backbone by specie and grouped nodes of it
          # @param [EngineCode] generator the major engine code generator
          # @param [Specie] specie for which algorithm will builded
          def initialize(generator, specie)
            @specie = specie
            @grouped_nodes = SpecieGroupedNodes.new(generator, specie).final_graph

            @_final_graph, @_node_to_nodes = nil
          end

          # Makes clean graph without not significant relations
          # @return [Hash] the grouped graph without reverse relations if them could be
          #   excepted
          def final_graph
            return @_final_graph if @_final_graph

            result =
              sequence.short.reduce(@grouped_nodes) do |acc, atom|
                limits = atom.relations_limits
                nodes = @grouped_nodes.keys.sort_by(&:size).find do |ns|
                  ns.any? { |n| n.atom == atom }
                end

                next acc unless acc[nodes]

                group_again(acc, nodes).reduce(acc) do |g, (rp, nbrs)|
                  raise 'Incomplete grouping in on prev step' unless nbrs.size == 1
                  # next line contain .reduce operation for case if incomplete
                  # grouping still takes plase
                  num = nbrs.reduce(0.0) { |acc, ns| acc + ns.size } / nodes.size
                  raise 'Node has too more relations' if limits[rp] < num

                  could_be_cleared = !atom.lattice || limits[rp] == num
                  unless could_be_cleared
                    lists = [nodes, nbrs.flatten].map { |ns| ns.map(&:properties) }
                    could_be_cleared = lists_are_identical?(*lists, &:==)
                  end

                  could_be_cleared ? without_reverse(g, nodes) : g
                end
              end

            @_final_graph = collaps_similar_key_nodes(result)
          end

          # Makes directed graph for walking find algorithm builder
          # @param [Array] nodes from wich reverse relations of final graph will
          #   be rejected
          # @param [Hash] directed graph without loops
          # @option [Hash] :init_graph the graph which uses as initial value for
          #   internal purging graph
          # @option [Set] :visited_key_nodes the set of visited nodes of internal
          #   purging graph
          # @return [Array] the ordered list that contains the ordered relations from
          #   final graph
          def ordered_graph_from(nodes, init_graph: nil, visited_key_nodes: Set.new)
            result = []
            directed_graph = init_graph || final_graph
            nodes_queue = nodes.dup

            until nodes_queue.empty?
              node = nodes_queue.shift
              new_nodes = node_to_nodes[node]
              next if visited_key_nodes.include?(new_nodes)

              visited_key_nodes << new_nodes
              rels = directed_graph[new_nodes]
              next unless rels

              result << [new_nodes, sort_rels_by_limits_of(new_nodes, rels)]
              next if rels.empty?

              directed_graph = without_reverse(directed_graph, new_nodes)
              nodes_queue += rels.flat_map(&:first)
            end

            connected_nodes_from(directed_graph).each do |ns|
              next if visited_key_nodes.include?(ns)
              result += ordered_graph_from(ns,
                init_graph: directed_graph, visited_key_nodes: visited_key_nodes)
            end

            unconnected_nodes_from(directed_graph).each do |ns|
              result << [ns, []] unless visited_key_nodes.include?(ns)
            end

            result
          end

        private

          def_delegators :@specie, :spec, :sequence

          # Groups key nodes of passed graph if them haven't relations and contains
          # similar unique species
          #
          # @param [Hash] graph which will be collapsed
          # @return [Hash] the collapsed graph
          def collaps_similar_key_nodes(graph)
            result = {}
            shrink_graph = graph.dup
            until shrink_graph.empty?
              nodes, rels = shrink_graph.shift

              uniq_specie_nodes = nodes.uniq(&:uniq_specie)
              if uniq_specie_nodes.size == 1 && rels.empty?
                uniq_specie = uniq_specie_nodes.first.uniq_specie
                similar_nodes = nodes
                shrink_graph.each do |ns, rs|
                  if rs.empty? && ns.all? { |n| n.uniq_specie == uniq_specie }
                    shrink_graph.delete(ns)
                    similar_nodes += ns
                  end
                end
                result[similar_nodes] = []
              else
                result[nodes] = rels
              end
            end
            result
          end

          # Makes mirror from each node to correspond nodes of grouped graph
          # @return [Hash] the mirror from each node to grouped graph nodes
          def node_to_nodes
            return @_node_to_nodes if @_node_to_nodes

            sorted_keys = @grouped_nodes.keys.sort_by(&:size)
            @_node_to_nodes =
              sorted_keys.each_with_object({}) do |nodes, result|
                nodes.each { |node| result[node] ||= nodes }
              end
          end

          # Collects similar relations that available by key of grouped graph
          # @param [Array] nodes the key of grouped graph
          # @return [Array] the array where each item is array that contains the
          #   following elements: first item is relation parameters, second item is
          #   array of all neighbour nodes groups available by passed key of grouped
          #   graph
          def group_again(graph, nodes)
            graph[nodes].group_by(&:last).map do |rp, group|
              [rp, group.map(&:first)]
            end
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
