module VersatileDiamond
  module Concepts

    # Uses for replasing similar sources in concepts that contain specs
    class VeiledSpec < Tools::TransparentProxy
      # Compares with other spec
      # @param [Spec | SpecificSpec | VeiledSpec] other with which the current instance
      #   will be compared
      # @return [Boolean] is same or not
      def same?(other)
        self.class == other.class ?
          original.same?(other.original) :
          original.same?(other)
      end

      def inspect
        "veiled:#{original.inspect}"
      end
    end

  end
end
