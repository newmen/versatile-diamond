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

            @_main, @_sources = nil
          end

          # @return [Array] the list of nodes pairs which represents the main changes
          def main
            @_main ||= apply_nodes(@reaction.changes).sort_by(&:first)
          end

          # @return [Array] the list of source nodes
          def sources
            @_sources ||= main.map(&:first)
          end

          # @return [Array] the list of nodes with adsorption atoms
          def come
            sources.select(&:gas?)
          end

          # @return [Array] the list of nodes with desorption atoms
          def away
            main.select { |_, prd| prd.gas? }.map(&:first)
          end

        private

          # @param [Array] changes
          # @return [Array]
          def apply_nodes(changes)
            changes.map do |src_to_prd|
              [@factory.source_node(*src_to_prd), @factory.product_node(*src_to_prd)]
            end
          end
        end

      end
    end
  end
end
