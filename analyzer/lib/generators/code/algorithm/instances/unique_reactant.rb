module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Instances

        # Wraps reactant specie code generator for difference naming when algorithm
        # builds
        class UniqueReactant < UniqueSpecie

          attr_reader :spec

          # Initializes unique reactant specie
          # @param [EngineCode] generator the major code generator
          # @param [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec]
          #   concept_spec by which the unique reactant specie will be maked
          def initialize(generator, concept_spec)
            super
            @spec = original.spec.clone_with_replace(concept_spec)
          end

          # Compares two unique specie that were initially high and then a small
          # @param [UniqueReactant] other comparable specie
          # @return [Integer] the comparing result
          # @override
          def <=> (other)
            comparing_core(other)
          end

        private

          # Gets the same atom as was passed
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom of current specie which will be returned
          # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   the passed atom
          def reflection_of(atom)
            atom
          end
        end

      end
    end
  end
end
