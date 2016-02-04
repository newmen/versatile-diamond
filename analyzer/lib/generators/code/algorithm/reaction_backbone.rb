module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Cleans the reaction grouped nodes graph from not significant relations and
        # gets the ordered graph by which the find reaction algorithm will be built
        class ReactionBackbone < BaseBackbone

          # Initializes backbone by reaction and reactant specie
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

            result = super.select { |nodes, _| all_of_current_specie?(nodes) }
            other_side_nodes(result).each do |nodes|
              result = extend_graph(result, nodes) unless nodes.any?(&:anchor?)
            end

            grouped_nodes = nodes_set(super)

            loop do
              result_nodes = nodes_set(result)
              break unless result_nodes.size < grouped_nodes.size
              nodes = super.keys.find { |k| k.to_set == result_nodes }
              result = extend_graph(result, nodes) if nodes
            end

            @_final_graph = result
          end

        private

          # Checks that passed nodes belongs to target specie
          # @param [Array] nodes which will be checked
          # @return [Boolean] are all nodes belongs to target specie or not
          def all_of_current_specie?(nodes)
            nodes.all? { |node| node.spec.spec == @specie.spec.spec }
          end

          # Extends passed graph from passed nodes
          # @param [Hash] graph which extended instance will be gotten
          # @param [Array] nodes from which graph will be extended
          # @return [Hash] the extended graph
          def extend_graph(graph, nodes)
            next_rels = next_ways(graph, nodes)
            return nil if next_rels.empty? # stop recursive find

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
            prev_nodes = nodes_set(graph)
            nodes.reduce([]) do |acc, node|
              rels = grouped_nodes_graph.big_graph[node].reject do |n, _|
                prev_nodes.include?(n)
              end
              rels.empty? ? acc : acc + rels.map { |n, r| [node, n, r.params] }
            end
          end

          # Collects the set of all used nodes from passed graph
          # @param [Hash] graph from which the nodes will be collected
          # @return [Set] the set of all used nodes
          def nodes_set(graph)
            collect_nodes(graph).flatten.to_set
          end

          # Gets the nodes list which uses in relations of passed graph
          # @param [Hash] graph from which relations the nodes will be gotten
          # @return [Array] the list of other side nodes
          def other_side_nodes(graph)
            bg = grouped_nodes_graph.big_graph
            graph.flat_map do |nodes, rels|
              rels.map do |nbrs, _|
                nodes.flat_map do |node|
                  bg[node].select { |n, r| r.exist? && nbrs.include?(n) }.map(&:first)
                end
              end
            end
          end
        end

      end
    end
  end
end
