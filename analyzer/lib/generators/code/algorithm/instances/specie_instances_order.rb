module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Instances

        # The base role for algorithm specie instances
        module SpecieInstancesOrder
          include Modules::OrderProvider

          # Compares two specie instances that were initially high and then a small
          # @param [SpecieInstance] other comparable specie
          # @return [Integer] the comparing result
          def <=> (other)
            typed_order(other, self, :scope?) do
              typed_order(self, other, :none?) do
                comparing_core(other)
              end
            end
          end

        private

          # Compares two unique specie that were initially high and then a small
          # @param [SpecieInstance] other comparable specie
          # @return [Integer] the comparing result
          def comparing_core(other)
            other.spec <=> spec
          end
        end

      end
    end
  end
end
