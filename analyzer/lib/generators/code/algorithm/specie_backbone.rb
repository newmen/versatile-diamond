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
            @_final_graph ||= clear_excess_rels(super)
          end

          # Provides the list of all atoms that uses in backbone full graph
          # @return [Array] the list of all used atoms
          def using_atoms
            # TODO: hack! Uses in MultiUnsymmetricParentsUnit#using_specie_atoms
            collect_nodes(final_graph).flatten.map(&:atom).uniq
          end

        private

          def_delegators :@specie, :spec, :sequence

          # Finds nodes from passed lists by passed atom
          # @param [Array] lists_of_nodes where result nodes will be found or not
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom by which the nodes will be found
          # @return [Array] nil or nodes any of which uses passed atom
          def find_nodes(lists_of_nodes, atom)
            lists_of_nodes.find { |nodes| nodes.any? { |node| node.atom == atom } }
          end

          # Clears passed graph from reverse relations in order sequenced atom in
          # original specie
          #
          # @param [Hash] graph which cleared analog will be returned
          # @return [Hash] the graph wihtout excess relations
          def clear_excess_rels(graph)
            all_nodes_lists = collect_nodes(graph)
            sequence.short.reduce(graph) do |acc, atom|
              nodes = find_nodes(all_nodes_lists, atom)
              acc[nodes] ? clear_reverse_rels(acc, nodes, atom) : acc
            end
          end

          # Clears reverse relations from passed graph for passed nodes and anchor atom
          #
          # Groups again because could be case:
          # {
          #   [1, 2] => [[[3, 4], flatten_rel], [5, 6], flatten_rel],
          #   [3, 4] => [[[1, 2], flatten_rel]],
          #   [5, 6] => [[[1, 2], flatten_rel]]
          # }
          #
          # @param [Hash] graph which cleared analog will be returned
          # @param [Array] nodes the set of similar nodes to which reverse relations
          #   will be excluded
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom by which the nodes was selected
          # @return [Hash] the graph wihtout excess reverse relations
          def clear_reverse_rels(graph, nodes, atom)
            limits = atom.relations_limits
            group_again(graph[nodes]).reduce(graph) do |acc, (rp, nbrs)|
              raise 'Incomplete grouping in on prev step' unless nbrs.size == 1

              all_nbrs = nbrs.flatten
              num = all_nbrs.size / nodes.size.to_f
              max_num = limits[rp]

              if max_num < num
                raise 'Node has too more relations'
              elsif !atom.lattice || max_num == num || equal_props?(nodes, all_nbrs)
                without_reverse(acc, nodes)
              else
                acc
              end
            end
          end

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

          # Compares the lists of atom properties which will maked from passed lists
          # of nodes
          #
          # @param [Array] lists_of_nodes each list of which will be converted to list
          #   of atom properties
          # @return [Boolean] are equal lists of atom properties or not
          def equal_props?(*lists_of_nodes)
            lists_of_props = lists_of_nodes.map { |ns| ns.map(&:properties) }
            lists_are_identical?(*lists_of_props, &:==)
          end
        end

      end
    end
  end
end
