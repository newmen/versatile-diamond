module VersatileDiamond
  module Concepts

    # Provides methods which garantees that instance with current module is not a bond
    module NoBond
      # Current instance is not a bond
      # @return [Boolean] false
      def bond?
        false
      end

      # Current instance is not a relation
      # @return [Boolean] false
      def relation?
        false
      end

      def inspect
        to_s
      end
    end

  end
end
