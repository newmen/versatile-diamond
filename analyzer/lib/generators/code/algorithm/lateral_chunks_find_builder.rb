module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contain logic for building lateral chunks algorithm
        # @abstract
        class LateralChunksFindBuilder < FindAlgorithmBuilder
          def initialize(*)
            super
            @_action_unit = nil
          end

        private

          # @return [Units::Expressions::LateralExprsDictionary]
          # @override
          def make_dict
            Units::Expressions::LateralExprsDictionary.new
          end

          # @param [Array] ordered_graph
          # @return [Units::LateralContextProvider]
          def make_context_provider(ordered_graph)
            Units::LateralContextProvider.new(dict, nodes_graph, ordered_graph)
          end

          # @return [Units::ActionTargetUnit]
          def action_unit
            @_action_unit ||=
              combine_context_factory([]).action_unit(backbone.action_nodes)
          end

          # Define by default
          # @return [Boolean]
          # @override
          def define_each_entry_node?
            false
          end

          # @return [Expressions::Core::Statement]
          # @override
          def complete_algorithm
            action_unit.predefine! do
              dict.checkpoint!
              super
            end
          end
        end

      end
    end
  end
end
