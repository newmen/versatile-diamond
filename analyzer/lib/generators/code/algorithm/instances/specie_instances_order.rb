module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Instances

        # The base role for algorithm specie instances
        module SpecieInstancesOrder
          # Compares two specie instances that were initially high and then a small
          # @param [SpecieInstance] other comparable specie
          # @return [Integer] the comparing result
          def <=>(other)
            spec <=> other.spec
          end
        end

      end
    end
  end
end
