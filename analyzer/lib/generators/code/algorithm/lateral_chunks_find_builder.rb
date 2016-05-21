module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contain logic for building lateral chunks algorithm
        # @abstract
        class LateralChunksFindBuilder < FindAlgorithmBuilder
          # Generates find algorithm cpp code
          # @return [String] the string with cpp code of find algorithm
          # @override
          def build
            pure_factory.unit(backbone.action_nodes).define!
            super
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
