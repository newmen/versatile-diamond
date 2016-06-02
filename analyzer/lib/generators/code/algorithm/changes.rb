module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Holds the changes which applies when reaction do
        class Changes

          attr_reader :reaction

          # @param [EngineCode] generator the major code generator
          # @param [TypicalReaction] reaction
          def initialize(generator, reaction)
            @reaction = reaction
            @factory = ChangesNodesFactory.new(generator)

            @_main = nil
          end

          # @return [Array] the list of nodes which represents the changes
          def main
            @_main ||= apply_nodes(@reaction.changes).sort
          end

          # @return [Array] the list of nodes with desorption atoms
          def away
            main.select { |node| node.product.gas? }
          end

        private

          # @param [Array] changes
          # @return [Array]
          def apply_nodes(changes)
            changes.map { |src_to_prd| @factory.source_node(*src_to_prd) }
          end
        end

      end
    end
  end
end
