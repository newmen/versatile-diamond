module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # The creator and cacher of unique species which stores the reference to
        # original concept specie
        class ProxyUniqueSpeciesProvider
          include SpeciesUser

          # Initializes the internal cache
          # @param [EngineCode] generator the major code generator
          def initialize(generator)
            @generator = generator
            @cache = {}
          end

          # Makes unique specie instance from passed spec
          # @param [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec]
          #   spec by which the unique algorithm specie will be maked
          # @return [UniqueSpecie] the wrapped specie code generator
          def get_unique_specie(spec)
            return @cache[spec] if @cache[spec]
            specie = specie_class(spec)
            dept_spec = specie.spec.clone_with_replace(spec)
            @cache[spec] = UniqueSpecie.new(specie, dept_spec)
          end

        private

          attr_reader :generator

        end

      end
    end
  end
end
