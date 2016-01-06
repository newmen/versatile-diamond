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
          # @param [Specie] original specie from which this scope was found
          # @param [Array] species which will be stored as one
          def initialize(original, species)
            super(original)
            @species = species
          end

          # Checks that passed atom is anchor of any internal specie
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which will be checked
          # @return [Boolean] is anchor or not
          def anchor?(atom)
            spec.anchors.include?(atom)
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
          # @override
          def comparing_core(other)
            species.sort <=> other.species.sort
          end
        end

      end
    end
  end
end
