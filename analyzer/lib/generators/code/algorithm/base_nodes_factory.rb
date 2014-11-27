module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # The base class for factories of nodes
        # @abstract
        class BaseNodesFactory
          include SpeciesUser

          # Initizalize nodes factory by general code generator
          # @param [EngineCode] generator the major code generator
          def initialize(generator)
            @generator = generator
            @vertices_to_nodes = {}
          end

          # Makes node for passed vertex
          # @return [Node] the node which contain the correspond algorithm specie and
          #   atom
          def get_node(vertex)
            @vertices_to_nodes[vertex] ||= create_node(vertex)
          end

        private

          attr_reader :generator

        end

      end
    end
  end
end
