module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Cleans the reaction grouped nodes graph from not significant relations and
        # gets the ordered graph by which the find reaction algorithm will be builded
        class ReactionBackbone < BaseBackbone
          extend Forwardable

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

            if result.empty?
              result[create_empty_nodes] = []
            else
              other_side_nodes = result.flat_map { |_, rels| rels.map(&:first) }
              other_side_nodes.each do |nodes|
                result = extend_graph(result, nodes) unless nodes.any?(&:anchor?)
              end
            end

            @_final_graph = result
          end

        private

          def_delegator :@grouped_nodes_graph, :big_graph

          # Checks that passed nodes belongs to target specie
          # @param [Array] nodes which will be checked
          # @return [Boolean] are all nodes belongs to target specie or not
          def all_of_current_specie?(nodes)
            nodes.all? { |node| node.uniq_specie.original == @specie }
          end

          # Creates empty nodes for case when reaction has just one reactant
          # @return [Array] the array with one node
          def create_empty_nodes
            uniq_specie = UniqueSpecie.new(@specie, @specie.spec)
            node = BluntNode.new(@specie, uniq_specie)
            [node]
          end

          # Extends passed graph from passed nodes
          # @param [Hash] graph which extended instance will be gotten
          # @param [Array] nodes from which graph will be extended
          # @return [Hash] the extended graph
          def extend_graph(graph, nodes)
            all_nodes = collect_nodes(graph).flatten.to_set
            curr_node_rels = nodes.each_with_object([]) do |node, acc|
              rels = big_graph[node].reject { |n, _| all_nodes.include?(n) }
              acc << [node, rels] unless rels.empty?
            end

            from_nodes, next_rels = curr_node_rels.transpose
            next_rels = next_rels.flatten(1)

            result = graph.dup
            next_rels.group_by(&:last).each do |rp, group|
              result[from_nodes] ||= []
              result[from_nodes] << [group.map(&:first).uniq, rp]
            end

            next_nodes = next_rels.map(&:first).uniq
            unless next_nodes.any?(&:anchor?)
              result = extend_graph(result, next_nodes)
            end
            result
          end
        end

      end
    end
  end
end