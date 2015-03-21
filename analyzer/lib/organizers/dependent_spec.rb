module VersatileDiamond
  module Organizers

    # @abstract
    class DependentSpec < DependentSimpleSpec

      # All species is not termination by default
      # @return [Boolean] false
      # @override
      def simple?
        false
      end

      # All species is not termination by default
      # @return [Boolean] false
      # @override
      def specific?
        false
      end
    end

  end
end
