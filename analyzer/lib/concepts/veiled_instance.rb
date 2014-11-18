module VersatileDiamond
  module Concepts

    # Uses for replasing similar concept instances
    class VeiledInstance < Tools::TransparentProxy
      # Compares with other veiled or original instance
      # @param [Object] other with which the current instance will be compared
      # @return [Boolean] is same or not
      def same?(other)
        if self.class == other.class
          original.same?(other.original)
        else
          original.same?(other)
        end
      end

      def inspect
        "veiled:#{original.inspect}"
      end
    end

  end
end
