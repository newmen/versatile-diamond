module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Instances

        # Provides specie which means "no specie"
        class NoneSpecie < SpecialCase
          include SpecieInstance

          define_alias :actual, :original

          # Intializes the none specie
          # @param [EngineCode] generator the major code generator
          # @param [Specie] original which is original and will be remembered
          def initialize(generator, original)
            super(original)
            @generator = generator
          end

          # "No specie" is always "no specie"
          # @return [Boolean] true
          def none?
            true
          end

          # "No specie" is not scope
          # @return [Boolean] false
          def scope?
            false
          end

          def inspect
            "none:#{original.inspect}"
          end

        protected

          define_itself_getter_by :self_atom

        private

          attr_reader :generator

          define_itself_getter_by :actual_atom, :original_atom

        end

      end
    end
  end
end
