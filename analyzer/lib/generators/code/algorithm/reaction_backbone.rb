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
            @reaction = reaction
            @specie = specie
            @grouped_nodes = ReactionGroupedNodes.new(generator, reaction).final_graph

binding.pry
            @_final_graph, @_node_to_nodes = nil
          end

          # Makes clean graph with relations only from target reactant
          # @return [Hash] the grouped graph with relations only from target reactant
          def final_graph
            @_final_graph ||=
              @grouped_nodes.each_with_object({}) do |(nodes, rels), acc|
                next unless nodes.all? { |node| node.uniq_specie.original == @specie }
                acc[nodes] = rels
              end
          end
        end

      end
    end
  end
end