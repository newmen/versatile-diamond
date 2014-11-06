module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contains many species as one
        class SpeciesScope
          # Initializes scope of species by original species list
          # @param [Array] species which will be stored as one
          def initialize(species)
            @species = species
          end

          # Scope is not "no specie"
          # @return [Boolean] false
          def none?
            false
          end

          # Scope always is scope
          # @return [Boolean] true
          def scope?
            true
          end

          def inspect
            "scope:<#{@species.map(&:inspect).join(', ')}>"
          end
        end

      end
    end
  end
end
