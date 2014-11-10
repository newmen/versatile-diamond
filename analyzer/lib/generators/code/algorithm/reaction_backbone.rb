module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Cleans the reaction grouped nodes graph from not significant relations and
        # gets the ordered graph by which the find reaction algorithm will be builded
        class ReactionBackbone
          # Initializes backbone by reaction, reactant specie and grouped nodes of it
          # @param [EngineCode] generator the major engine code generator
          # @param [TypicalReaction] reaction the target reaction code generator
          # @param [Specie] specie the reactant from which search will be occured
          def initialize(generator, reaction, specie)
            @generator = generator
            @reaction = reaction
            @specie = specie

            @_final_graph, @_node_to_nodes = nil
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

            grouped_nodes = ReactionGroupedNodes.new(@generator, @reaction).final_graph
            result ||= grouped_nodes.each_with_object({}) do |(nodes, rels), acc|
              acc[nodes] = rels if all_of_current_specie?(nodes)
            end

            if result.empty?
              result[create_empty_nodes] = []
            else
              other_side_nodes = result.values.map(&:first)
              result = extend_by_other_side(result, other_side_nodes)
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

          # Creates empty nodes for case when reaction has just one reactant
          # @return [Array] the array with one node
          def create_empty_nodes
            uniq_specie = UniqueSpecie.new(@specie, @specie.spec)
            node = BluntNode.new(@specie, uniq_specie)
            [node]
          end

          def extend_by_other_side(graph, other_side_nodes, parents_stack = [])
            other_side_nodes.each_with_object(graph) do |nodes, acc|
              if nodes.any?(&:anchor?)
                acc[nodes] = stack_back_rels(parents_stack, nodes)
              else
                nodes.group_by(&:uniq_specie).each do |pr, ns|
                  # parent_nodes = ns.map(&:parent)
                  # extend_by_other_side(acc, parent_nodes, parents_stack + [pr])
                end
              end
            end
          end

          def stack_back_rels(parents_stack, prev_nodes)

          end
        end

      end
    end
  end
end