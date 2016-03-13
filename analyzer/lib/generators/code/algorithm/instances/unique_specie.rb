module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Instances

        # Wraps real specie code generator for difference naming when algorithm builds
        # @abstract
        class UniqueSpecie < Tools::TransparentProxy
          include SpeciesUser
          include SpecieInstance
          include SpecieInstancesOrder

          # Initializes unique specie
          # @param [EngineCode] generator the major code generator
          # @param [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec]
          #   concept_spec by which the unique algorithm specie will be maked
          def initialize(generator, concept_spec)
            @generator = generator
            super(specie_class(concept_spec))

            @_original_mirror = nil
          end

        private

          attr_reader :generator

          # Gets the instance of atom which uses in original specie
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which corresponding instance from original specie will be gotten
          # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   the atom from original specie
          def original_atom(atom)
            original_mirror[reflection_of(atom)]
          end

          # Gets the mirror from proxy spec to original spec
          # @return [Hash] the mirror from current spec to original spec
          def original_mirror
            @_original_mirror ||=
              Mcs::SpeciesComparator.make_mirror(spec, original.spec).freeze
          end
        end

      end
    end
  end
end
