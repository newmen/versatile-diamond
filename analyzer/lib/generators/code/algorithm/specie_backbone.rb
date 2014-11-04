module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Provides logic for generation the find specie algorithm
        class SpecieBackbone
          include Modules::ListsComparer
          extend Forwardable

          # Initializes algorithm by specie and grouped nodes of it
          # @param [Specie] specie for which algorithm will builded
          def initialize(generator, specie)
            @specie = specie
            @grouped_nodes = SpecieGroupedNodes.new(generator, specie).final_graph

            @_final_graph, @_atom_to_nodes = nil
          end

          # Makes algorithm graph by which code of algorithm will be generated
          # @return [Hash] the grouped graph without reverse relations if them could be
          #   excepted
          # TODO: must be private
          def final_graph
            @_final_graph ||=
              sequence.short.reduce(@grouped_nodes) do |acc, atom|
                limits = atom.relations_limits
                nodes = atom_to_nodes[atom]

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
          end

          # Makes directed graph for walking find algorithm builder
          # @param [Array] atoms from wich reverse relations of final graph will
          #   be rejected
          # @param [Hash] directed graph without loops
          # @option [Hash] :init_graph the graph which uses as initial value for
          #   internal purging graph
          # @option [Set] :visited_nodes the set of visited nodes of internal purging
          #   graph
          # @return [Array] the ordered list that contains the ordered relations from
          #   final graph
          # TODO: must be private
          def ordered_graph_from(atoms, init_graph: nil, visited_nodes: Set.new)
            result = []
            directed_graph = init_graph || final_graph
            atoms_queue = atoms.dup

            until atoms_queue.empty?
              atom = atoms_queue.shift
              nodes = atom_to_nodes[atom]
              next if visited_nodes.include?(nodes)

              visited_nodes << nodes
              rels = directed_graph[nodes]
              next unless rels

              result << [nodes, sort_rels_by_limits_of(nodes, rels)]
              next if rels.empty?

              directed_graph = without_reverse(directed_graph, nodes)
              atoms_queue += rels.flat_map(&:first).map(&:atom)
            end

            connected_nodes_from(directed_graph).each do |nodes|
              next if visited_nodes.include?(nodes)
              params = { init_graph: directed_graph, visited_nodes: visited_nodes }
              result += ordered_graph_from(nodes.map(&:atom), params)
            end

            unconnected_nodes_from(directed_graph).each do |nodes|
              result << [nodes, []] unless visited_nodes.include?(nodes)
            end

            result
          end

          # Reduces directed graph maked from passed atoms
          # @param [Object] init_value for reduce operation
          # @param [Array] atoms see at #ordered_graph_from same argument
          # @param [Proc] relations_proc do for each anchors and their neighbour atoms
          #   with using a relation parameters between them
          # @param [Proc] complex_proc do for each single anchor which no have
          #   neighbour atoms
          def reduce_directed_graph_from(init_value, atoms, relations_proc, complex_proc)
            ordered_graph_from(atoms).reduce(init_value) do |ext_acc, (anchors, rels)|
              if rels.empty?
                complex_proc[ext_acc, anchors.first]
              else
                rels.reduce(ext_acc) do |int_acc, (nbrs, relation_params)|
                  relations_proc[int_acc, anchors, nbrs, relation_params]
                end
              end
            end
          end

        private

          def_delegators :@specie, :spec, :sequence

          # Makes mirror from each node to correspond nodes of grouped graph
          # @return [Hash] the mirror from each node to grouped graph nodes
          def atom_to_nodes
            return @_atom_to_nodes if @_atom_to_nodes

            sorted_keys = @grouped_nodes.keys.sort_by(&:size)
            @_atom_to_nodes =
              sorted_keys.each_with_object({}) do |nodes, result|
                nodes.each { |node| result[node.atom] ||= nodes }
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
          # @param [Proc] reject_proc the function which reject neighbours atoms
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
              max_limit = nodes.map { |n| n.atom.relations_limits[rel_params] }.max
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
            nodes = graph.select { |_, rels| rels.empty? }.map(&:first)
            nodes.each do |ns|
              raise 'Invalid unconnected key' unless ns.size == 1
            end
            nodes
          end
        end

      end
    end
  end
end
