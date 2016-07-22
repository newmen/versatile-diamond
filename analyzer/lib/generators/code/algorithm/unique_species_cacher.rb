module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # The creator and cacher of unique species which stores the reference to
        # original concept specie
        class UniqueSpeciesCacher

          # Initializes the internal cache
          # @param [EngineCode] generator the major code generator
          # @param [Class] klass of creating unique species
          def initialize(generator, klass)
            @generator = generator
            @klass = klass
            @cache = {}
          end

          # Makes unique specie instance from passed spec
          # @param [Object] spec by which the unique specie will be created and cached
          # @return [Instances::UniqueSpecie] the wrapped specie code generator
          def get_unique_specie(spec)
            @cache[spec] ||= @klass.new(@generator, spec)
          end
        end

      end
    end
  end
end
