module VersatileDiamond
  module Concepts

    # Provides ability to order bonds for the bond instances
    module BondsOrderer
      include Modules::OrderProvider

      # Provides the order for bond instances
      # @param [BondsOrderer] other comparing instance
      # @return [Integer] the comparing result
      def <=>(other)
        typed_order(self, other, Position) do
          typed_order(self, other, MultiBond) do
            typed_order(self, other, Bond) do
              comparing_core(other)
            end
          end
        end
      end
    end

  end
end
