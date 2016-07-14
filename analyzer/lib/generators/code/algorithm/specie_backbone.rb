module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Cleans the specie grouped nodes graph from not significant relations and
        # gets the ordered graph by which the find specie algorithm will be built
        class SpecieBackbone < BaseBackbone
          extend Forwardable

          # Initializes backbone by specie and grouped nodes of it
          # @param [EngineCode] generator the major engine code generator
          # @param [Specie] specie for which algorithm will built
          def initialize(generator, specie)
            super(SpecieGroupedNodes.new(generator, specie))
            @specie = specie

            @_final_graph = nil
          end

          # Gets entry nodes for generating algorithm
          # @return [Array] the array of entry nodes
          def entry_nodes
            SpecieEntryNodes.new(final_graph).list
          end

          # Makes clean graph without not significant relations
          # @return [Hash] the grouped graph without reverse relations if them could be
          #   excepted
          # TODO: must be private!
          def final_graph
            @_final_graph ||= clear_excess_rels(super)
          end

        private

          def_delegators :@specie, :spec, :sequence

          # Checks that all nodes in passed lists are contained anchor atoms
          # @param [Array] lists_of_nodes which internal nodes will be checked
          # @return [Boolean] are all nodes have anchor atoms or not
          def all_anchored?(lists_of_nodes)
            lists_of_nodes.flatten.all? { |node| node.anchor? || node.none? }
          end

          # Finds nodes from passed lists by passed atom
          # @param [Array] lists_of_nodes where result nodes will be found or not
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom by which the nodes will be found
          # @return [Array] nil or nodes any of which uses passed atom
          def find_nodes(lists_of_nodes, atom)
            lists_of_nodes.find do |nodes|
              nodes.any? { |node| node.atom == atom }
            end
          end

          # Iterates each atom from specie atoms sequence, gets nodes for it and passes
          # graph, nodes and atom to block
          #
          # @param [Hash] graph the new instance of which will be returned after
          #   iteration done
          # @param [Array] all_nodes_lists the list of all nodes from original graph
          # @yield [Hasn, Array, Atom] iterates each described triples and accumulates
          #   the result as next value of graph
          # @return [Hash] the graph which was modified under iteration
          def through_sequence(graph, all_nodes_lists, &block)
            sequence.short.reduce(graph) do |acc, atom|
              nodes = find_nodes(all_nodes_lists, atom)
              block[acc, nodes, atom]
            end
          end

          # Clears passed graph from reverse relations in order sequenced atom in
          # original specie
          #
          # @param [Hash] graph which cleared analog will be returned
          # @return [Hash] the graph wihtout excess relations
          def clear_excess_rels(graph)
            all_nodes_lists = collect_nodes(graph)

            unless all_anchored?(all_nodes_lists)
              graph = setup_anchored_order(graph, all_nodes_lists)
            end

            through_sequence(graph, all_nodes_lists) do |acc, nodes, atom|
              acc[nodes] ? full_clear_reverse_rels(acc, nodes, atom) : acc
            end
          end

          # Removes from passed graph the links which related from anchored nodes to
          # nodes which haven't  parent species anchor atoms
          #
          # @param [Hash] graph the initial (and final) value of reduce opretation
          # @param [Array] all_nodes_lists the list of all nodes from original graph
          # @return [Hash] the graph without excess relations
          def setup_anchored_order(graph, all_nodes_lists)
            through_sequence(graph, all_nodes_lists) do |acc, nodes, _|
              if acc[nodes]
                keep_anchored_rels(acc, nodes)
              else
                acc[nodes] = [] if uniq_anchored?(nodes, all_nodes_lists)
                acc
              end
            end
          end

          # Does one removing of excess unanchored relation
          # @param [Hash] graph the initial (and final) value of reduce opretation
          # @param [Array] nodes which relations will be verified
          # @return [Hash] the graph without excess unanchored relation
          def keep_anchored_rels(graph, nodes)
            clean_relations = anchored_relations(nodes, graph[nodes])
            clean_relations.reduce(graph) do |acc, (nbrs, _)|
              without_reverse(acc, nodes, [nbrs])
            end
          end

          # Selects relations to nodes which atoms are anchors in parent species
          # @param [Array] nodes which relations will be filtered
          # @param [Array] relations from which the anchored relations will be selected
          # @return [Array] the list of relations to nodes with parent anchors
          def anchored_relations(nodes, relations)
            uniq_species = nodes.map(&:uniq_specie).uniq
            relations.select do |neighbours, _|
              neighbours.all? do |node|
                node.anchor? || uniq_species.include?(node.uniq_specie)
              end
            end
          end

          # Checks that another anchored nodes are exists in passed lists of nodes
          # @param [Array] nodes it is possible that last anchored nodes for correspond
          #   parent specie
          # @param [Array] lists_of_nodes where will be cheking another anchored nodes
          # @return [Boolean] is exists at least one other anchored node for same
          #   parent specie or not
          def uniq_anchored?(nodes, lists_of_nodes)
            return false unless nodes.all?(&:anchor?)
            all_other_nodes = lists_of_nodes.flatten - nodes
            other_anchored_nodes = all_other_nodes.select(&:anchor?)
            return false if !all_other_nodes.empty? && other_anchored_nodes.empty?

            !nodes.map(&:uniq_specie).uniq.all? do |uniq_specie|
              other_anchored_nodes.any? do |node|
                node.uniq_specie == uniq_specie ||
                  (node.scope? && node.uniq_specie.species.include?(uniq_specie))
              end
            end
          end

          # Clears reverse relations from passed graph for passed nodes and anchor atom
          #
          # Groups again because could be case:
          # {
          #   [1, 2] => [[[3, 4], flatten_rel], [[5, 6], flatten_rel]],
          #   [3, 4] => [[[1, 2], flatten_rel]],
          #   [5, 6] => [[[1, 2], flatten_rel]]
          # }
          #
          # @param [Hash] graph which cleared analog will be returned
          # @param [Array] nodes the set of similar nodes to which reverse relations
          #   will be excluded
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom by which the nodes were selected
          # @return [Hash] the graph wihtout excess reverse relations
          def full_clear_reverse_rels(graph, nodes, atom)
            is_latticed = !!atom.lattice
            limits = atom.relations_limits

            group_again(graph[nodes]).reduce(graph) do |acc, (rp, nbrs)|
              all_nbrs = nbrs.flatten
              num = (all_nbrs.size / nodes.size.to_f).round
              max_num = limits[rp]

              if max_num < num
                raise 'Node has too more relations'
              elsif !is_latticed || max_num == num || equal_props?(nodes, all_nbrs)
                without_reverse(acc, nodes)
              else
                acc
              end
            end
          end

          # Collects similar relations that available by key of grouped graph
          # @param [Array] relations which will be grouped
          # @return [Array] the array where each item is array that contains the
          #   following elements: first item is relation parameters, second item is
          #   array of all neighbour nodes which uses such relation
          def group_again(relations)
            relations.group_by(&:last).map do |rel_props, group|
              [rel_props, group.map(&:first)]
            end
          end

          # Compares the lists of atom properties which will maked from passed lists
          # of nodes
          #
          # @param [Array] lists_of_nodes each list of which will be converted to list
          #   of atom properties
          # @return [Boolean] are equal lists of atom properties or not
          def equal_props?(*lists_of_nodes)
            lists_are_identical?(*lists_of_nodes.map { |ns| ns.map(&:properties) })
          end

          # Also sorts the result list of connected nodes
          # @param [Hash] graph in which connected nodes will be found
          # @return [Array] the list of connected nodes
          def connected_nodes_from(graph)
            SpecieEntryNodes.sort(super)
          end

          # Also sorts the result list of unconnected nodes
          # @param [Hash] graph in which unconnected nodes will be found
          # @return [Array] the list of unconnected nodes
          def unconnected_nodes_from(graph)
            SpecieEntryNodes.sort(super)
          end

          # Builds the next part of sequence of find algorithm steps by nodes which
          # are relates to already added nodes
          #
          # @param [Hash] graph the graph which uses for receive next nodes
          # @param [Set] visited nodes
          # @return [Array] the sequence of nodes which were not added under building
          #   main sequence of find algorithm steps
          # @override
          def build_next_sequence(graph, visited)
            pretendents = rest_nodes(graph, visited)
            result = visited.to_a.reduce([]) do |acc, nodes|
              bests = best_same_nodes(nodes, pretendents)
              next acc if bests.empty? || visited.include?(bests.to_set) # cause recur
              acc + build_sequence_from(graph, bests, visited)
            end

            result + super(graph, visited)
          end

          # Collects unvisited nodes
          # @param [Hash] graph where rest nodes will be found
          # @param [Set] visited nodes
          # @return [Array] the list of not visited nodes
          def rest_nodes(graph, visited)
            collect_nodes(graph).reject { |nodes| visited.include?(nodes.to_set) }
          end

          # Finds the best nodes from available lists of nodes
          # @param [Array] nodes which analogies will be found
          # @param [Array] lists_of_nodes where the best will be found
          # @return [Array] the nodes which uses unique species as in passed nodes
          def best_same_nodes(nodes, lists_of_nodes)
            uniq_species = nodes.map(&:uniq_specie)
            sized_groups = lists_of_nodes.group_by do |ns|
              (uniq_species & ns.map(&:uniq_specie)).size
            end

            return [] if sized_groups.empty?

            max_num = sized_groups.max_by(&:first).first
            bests = sized_groups.select { |num, _| num == max_num }.flat_map(&:last)
            SpecieEntryNodes.sort(bests).first
          end
        end

      end
    end
  end
end
