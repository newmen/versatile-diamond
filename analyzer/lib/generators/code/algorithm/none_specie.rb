module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Provides specie which means "no specie"
        class NoneSpecie
          # Initialize "no specie" by original specie
          # @param [Specie] specie which will be remembered
          def initialize(specie)
            @specie = specie
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
            "none:#{@specie.inspect}"
          end
        end

      end
    end
  end
end
