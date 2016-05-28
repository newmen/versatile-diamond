module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Instances

        # Wraps reactant specie code generator for difference naming when algorithm
        # builds
        class UniqueReactant < UniqueSpecie

          alias_method :actual, :original
          attr_reader :spec

          # Initializes unique reactant specie
          # @param [EngineCode] generator the major code generator
          # @param [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec]
          #   concept_spec by which the unique reactant specie will be maked
          def initialize(generator, concept_spec)
            super
            @spec = original.spec.clone_with_replace(concept_spec)

            @_original_mirror, @_inverted_original_mirror = nil
          end

          # Compares two unique specie that were initially high and then a small
          # @param [UniqueReactant] other comparable specie
          # @return [Integer] the comparing result
          # @override
          def <=>(other)
            comparing_core(other)
          end

          # @return [Boolean]
          def proxy?
            false
          end

        protected

          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          def self_atom(atom)
            inverted_original_mirror[atom]
          end

        private

          define_alias :actual_atom, :original_atom

          # Gets the instance of atom which uses in original specie
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which corresponding instance from original specie will be gotten
          # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   the atom from original specie
          def original_atom(atom)
            original_mirror[atom]
          end

          # Gets the mirror from proxy spec to original spec
          # @return [Hash] the mirror from current spec to original spec
          def original_mirror
            @_original_mirror ||=
              Mcs::SpeciesComparator.make_mirror(spec, original.spec).freeze
          end

          # @return [Hash]
          def inverted_original_mirror
            @_inverted_original_mirror ||= original_mirror.invert
          end
        end

      end
    end
  end
end
