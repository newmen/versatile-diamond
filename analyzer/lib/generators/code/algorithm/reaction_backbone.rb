module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Cleans the reaction grouped nodes graph from not significant relations and
        # gets the ordered graph by which the find reaction algorithm will be builded
        class ReactionBackbone < BaseBackbone

          # Initializes backbone by reaction, reactant specie and grouped nodes of it
          # @param [EngineCode] generator the major engine code generator
          # @param [TypicalReaction] reaction the target reaction code generator
          # @param [Specie] specie the reactant from which search will be occured
          def initialize(generator, reaction, specie)
            super(ReactionGroupedNodes.new(generator, reaction))
            @reaction = reaction
            @specie = specie

            @_final_graph = nil
          end

          # Gets entry nodes for generating algorithm
          # @return [Array] the array of entry nodes
          def entry_nodes
            [final_graph.keys.find(&method(:all_of_current_specie?))]
          end

          # Makes clean graph with relations only from target reactant
          # @return [Hash] the grouped graph with relations only from target reactant
          # TODO: must be private!
          def final_graph
            return @_final_graph if @_final_graph

            result = super.each_with_object({}) do |(nodes, rels), acc|
              acc[nodes] = rels if all_of_current_specie?(nodes)
            end

            other_side_nodes = result.flat_map { |_, rels| rels.map(&:first) }
            other_side_nodes.each do |nodes|
              result = extend_graph(result, nodes) unless nodes.any?(&:anchor?)
            end

            @_final_graph = result
          end

        private

          # Checks that passed nodes belongs to target specie
          # @param [Array] nodes which will be checked
          # @return [Boolean] are all nodes belongs to target specie or not
          def all_of_current_specie?(nodes)
            nodes.all? { |node| node.uniq_specie.original == @specie }
          end

          # Extends passed graph from passed nodes
          # @param [Hash] graph which extended instance will be gotten
          # @param [Array] nodes from which graph will be extended
          # @return [Hash] the extended graph
          def extend_graph(graph, nodes)
            next_rels = next_ways(graph, nodes)
            return nil if next_rels.empty? # result of recursive find

            result = nil
            next_rels.group_by(&:last).each do |rp, group|
              from_nodes, next_nodes =
                group.map { |fn, nn, _| [fn, nn] }.transpose.map(&:uniq)

              ext_graph = graph.dup
              ext_graph[from_nodes] ||= []
              ext_graph[from_nodes] += [[next_nodes, rp]]

              result =
                if next_nodes.any?(&:anchor?)
                  ext_graph
                else
                  extend_graph(ext_graph, next_nodes)
                end
              break if result
            end

            result
          end

          # Gets the next ways by which the target graph could be extended
          # @param [Hash] graph for which the extending ways will be gotten
          # @param [Array] nodes from which ways will be found
          # @return [Array] the list of triples where first item of triple is
          #   from_node, the second item is next_node and last item is relation
          #   parameters hash
          def next_ways(graph, nodes)
            nodes_set = nodes.to_set
            anchors_set = anchor_nodes(graph).to_set

            prev_nodes = anchors_set + nodes_set
            key_nodes = anchors_set & nodes_set
            key_nodes = nodes_set if key_nodes.empty?

            key_nodes.reduce([]) do |acc, node|
              rels = grouped_nodes_graph.big_graph[node].reject do |n, _|
                prev_nodes.include?(n) || n.uniq_specie != node.uniq_specie
              end
              rels.empty? ? acc : acc + rels.map { |n, r| [node, n, r.params] }
            end
          end

          # Selects the nodes from graph which presented in small grouped graph
          # @param [Hash] graph from which the nodes will be selected
          # @return [Array] the list of anchor nodes
          def anchor_nodes(graph)
            small_nodes = grouped_nodes_graph.small_graph.keys.to_set
            collect_nodes(graph).flatten.select { |n| small_nodes.include?(n) }
          end
        end

      end
    end
  end
end
