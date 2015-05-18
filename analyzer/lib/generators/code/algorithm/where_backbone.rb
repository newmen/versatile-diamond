module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Provides logic for make the backbone of sidepiece check algorithm
        class WhereBackbone < BaseBackbone

          # Initializes backbone by where logic object
          # @param [EngineCode] generator the major engine code generator
          # @param [WhereLogic] reaction the target reaction code generator
          def initialize(generator, where)
            super(WhereGroupedNodes.new(generator, where))
          end

          # Gets entry nodes for generating algorithm
          # @return [Array] the array of entry nodes
          def entry_nodes
            final_graph.keys
          end
        end

      end
    end
  end
end
