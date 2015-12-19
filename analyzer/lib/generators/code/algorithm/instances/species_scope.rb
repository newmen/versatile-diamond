module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Instances

        # Contains many species as one
        # Scope haven't common interface with another specie instances, thus should be
        # splited before using
        class SpeciesScope < SpecialCase

          attr_reader :species

          # Initializes scope of species by original species list
          # @param [EngineCode] generator the major code generator
          # @param [Specie] original specie from which this scope was found
          # @param [Array] species which will be stored as one
          def initialize(generator, original, species)
            super(generator, original)
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
            "scope:<#{species.map(&:inspect).join(', ')}>"
          end

        private

          # Compares two scope instances that were initially high and then a small
          # @param [Comparator] other comparable instance
          # @return [Integer] the comparing result
          def comparing_core(other)
            species.sort <=> other.species.sort
          end
        end

      end
    end
  end
end
