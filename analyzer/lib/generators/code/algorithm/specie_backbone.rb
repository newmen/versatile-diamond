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
                nodes = all_nodes_lists.find do |ns|
                  ns.any? { |n| n.atom == atom }
                end

                next acc unless acc[nodes]

                limits = atom.relations_limits
                # Groups again because could be case:
                # {
                #   [1, 2] => [[[3, 4], flatten_rel], [5, 6], flatten_rel],
                #   [3, 4] => [[[1, 2], flatten_rel]],
                #   [5, 6] => [[[1, 2], flatten_rel]]
                # }
                group_again(acc[nodes]).reduce(acc) do |g, (rp, nbrs)|
                  raise 'Incomplete grouping in on prev step' unless nbrs.size == 1
                  # next line contain .reduce operation for case if incomplete
                  # grouping still takes plase
                  num = nbrs.reduce(0) { |acc, ns| acc + ns.size } / nodes.size.to_f
                  raise 'Node has too more relations' if limits[rp] < num

                  could_be_cleared = !atom.lattice || limits[rp] == num
                  unless could_be_cleared
                    lists = [nodes, nbrs.flatten].map { |ns| ns.map(&:properties) }
                    could_be_cleared = lists_are_identical?(*lists, &:==)
                  end

                  could_be_cleared ? without_reverse(g, nodes) : g
                end
              end

            @_final_graph = result
          end

        private

          def_delegators :@specie, :spec, :sequence

          # Collects similar relations that available by key of grouped graph
          # @param [Array] rels the relations which will be grouped
          # @return [Array] the array where each item is array that contains the
          #   following elements: first item is relation parameters, second item is
          #   array of all neighbour nodes groups available by passed key of grouped
          #   graph
          def group_again(rels)
            rels.group_by(&:last).map do |rp, group|
              [rp, group.map(&:first)]
            end
          end
        end

      end
    end
  end
end
