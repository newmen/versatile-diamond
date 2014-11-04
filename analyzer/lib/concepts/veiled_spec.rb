module VersatileDiamond
  module Concepts

    # Uses for replasing similar sources in concepts that contain specs
    class VeiledSpec < Tools::TransparentProxy
      # @override
      def == (other)
        self.class == other.class ? original == other.original : original == other
      end

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
