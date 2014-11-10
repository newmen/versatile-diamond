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
            @atoms_to_nodes = {}
          end

        private

          attr_reader :generator, :atoms_to_nodes

        end

      end
    end
  end
end
