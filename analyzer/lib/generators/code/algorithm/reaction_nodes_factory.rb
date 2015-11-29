module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates nodes for reaction algorithm graphs building
        class ReactionNodesFactory < BaseNodesFactory
          # Initizalize reaction nodes factory
          # @param [EngineCode] generator the major code generator
          def initialize(generator)
            super(generator)
            @unique_species_provider = ProxyUniqueSpeciesProvider.new(generator)
          end

        private

          # Creates node for passed spec with atom
          # @return [Node] new node which contain the correspond algorithm specie and
          #   atom
          def create_node(spec_atom)
            spec, atom = spec_atom
            specie = @unique_species_provider.get_unique_specie(spec)
            ReactantNode.new(specie.original, specie, atom)
          end
        end

      end
    end
  end
end
