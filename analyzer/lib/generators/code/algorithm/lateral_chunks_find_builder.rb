module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contain logic for building lateral chunks algorithm
        # @abstract
        class LateralChunksFindBuilder < FindAlgorithmBuilder
          extend Forwardable

        private

          def_delegator :backbone, :action_nodes

          # @return [Units::Expressions::LateralExprsDictionary]
          # @override
          def make_dict
            Units::Expressions::LateralExprsDictionary.new(action_nodes)
          end

          # @param [Array] ordered_graph
          # @return [Units::LateralContextProvider]
          def make_context_provider(ordered_graph)
            Units::LateralContextProvider.new(dict, nodes_graph, ordered_graph)
          end

          # @return [Units::ActionTargetUnit]
          def make_action_unit
            combine_context_factory([]).action_unit(action_nodes)
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
            make_action_unit.predefine! { super }
          end
        end

      end
    end
  end
end
