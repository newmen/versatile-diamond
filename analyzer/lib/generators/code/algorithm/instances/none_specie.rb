module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Instances

        # Provides specie which means "no specie"
        class NoneSpecie < SpecialCase

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
        end

      end
    end
  end
end
