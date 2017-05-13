module VersatileDiamond
  module Concepts

    # Uses for replasing similar concept instances
    class VeiledInstance < Tools::TransparentProxy

      delegate :name, :same?

      def inspect
        "veiled_#{i}:#{original.inspect}"
      end
    end

  end
end
