module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contain logic for building lateral chunks algorithm
        # @abstract
        class LateralChunksFindBuilder < FindAlgorithmBuilder
          extend Forwardable

          # Generates find algorithm cpp code
          # @return [String] the string with cpp code of find algorithm
          # @override
          def build
            pure_factory.unit(action_nodes).define!
            super
          end

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
            context_class = Units::LateralContextProvider
            context_class.new(dict, nodes_graph, ordered_graph, action_nodes)
          end

          # Define by default
          # @return [Boolean]
          # @override
          def define_each_entry_node?
            false
          end

          # @param [Array] nodes which will not defined again
          # @return [Expressions::Core::Statement]
          # @override
          def define_algorithm(nodes)
            combine_algorithm(nodes)
          end
        end

      end
    end
  end
end
