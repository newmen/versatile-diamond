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
          end

        private

          attr_reader :generator

        end

      end
    end
  end
end
