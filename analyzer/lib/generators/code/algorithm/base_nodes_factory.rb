module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # The base class for factories of nodes
        # @abstract
        class BaseNodesFactory
          extend Forwardable

          # Initizalize nodes factory by general code generator
          # @param [EngineCode] generator the major code generator
          def initialize(generator)
            @generator = generator
            @unique_species_cacher = UniqueSpeciesCacher.new(generator, instance_class)
            @vertices_to_nodes = {}
          end

          # Makes node for passed vertex
          # @param [Object] vertex by which the new node will be maked
          # @return [BaseNode] the node which contain the correspond algorithm specie
          #   and atom
          def get_node(vertex)
            @vertices_to_nodes[vertex] ||= create_node(vertex)
          end

        private

          attr_reader :generator
          def_delegator :@unique_species_cacher, :get_unique_specie

        end

      end
    end
  end
end
