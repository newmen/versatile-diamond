module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Cleans the reaction grouped nodes graph from not significant relations and
        # gets the ordered graph by which the find reaction algorithm will be built
        class ReactionBackbone < BaseBackbone
          include BackboneExtender

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
            [final_graph.keys.find(&method(:own_key?))]
          end

          # Makes clean graph with relations only from target reactant
          # @return [Hash] the grouped graph with relations only from target reactant
          # TODO: must be private!
          def final_graph
            @_final_graph ||= cut_and_extend_to_anchors(complete_grouped_graph)
          end

        private

          # Checks that passed nodes belongs to target specie
          # @param [Array] nodes which will be checked
          # @return [Boolean] are all nodes belongs to target specie or not
          def own_key?(nodes)
            nodes.all? { |node| node.spec.spec == @specie.spec.spec }
          end
        end

      end
    end
  end
end
