module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contain logic for building lateral chunks algorithm
        # @abstract
        class LateralChunksFindBuilder < FindAlgorithmBuilder
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
        end

      end
    end
  end
end
