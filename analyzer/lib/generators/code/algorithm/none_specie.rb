module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Provides specie which means "no specie"
        class NoneSpecie

          def initialize(specie)
            @specie = specie
          end

          def inspect
            "none:#{@specie.inspect}"
          end
        end

      end
    end
  end
end
