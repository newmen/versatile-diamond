module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contain logic for clean links of reaction and group them by parameters
        # of relations
        class ReactionGroupedNodes
          # Initizalize grouper by reaction class code generator
          # @param [Specie] reaction from which grouped graph will be gotten
          def initialize(reaction)
            @reaction = reaction
            @_grouped_graph = nil
          end


          def grouped_graph
            return @_grouped_graph if @_grouped_graph

            result = {}

          end
        end

      end
    end
  end
end
