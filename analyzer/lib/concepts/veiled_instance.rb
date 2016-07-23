module VersatileDiamond
  module Concepts

    # Uses for replasing similar concept instances
    class VeiledInstance < Tools::TransparentProxy

      binary_operations :same?

      def inspect
        "veiled_#{i}:#{original.inspect}"
      end
    end

  end
end
