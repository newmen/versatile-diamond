module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Cleans the specie grouped nodes graph from not significant relations and
        # gets the ordered graph by which the find specie algorithm will be builded
        class SpecieBackbone < BaseBackbone
          include Modules::ListsComparer
          extend Forwardable

          # Initializes backbone by specie and grouped nodes of it
          # @param [EngineCode] generator the major engine code generator
          # @param [Specie] specie for which algorithm will builded
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
            return @_final_graph if @_final_graph

            all_nodes_lists = collect_nodes(super)
            result =
              sequence.short.reduce(super) do |acc, atom|
                limits = atom.relations_limits
                nodes = all_nodes_lists.find do |ns|
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
        end

      end
    end
  end
end
