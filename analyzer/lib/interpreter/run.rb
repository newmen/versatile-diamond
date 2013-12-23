module VersatileDiamond
  module Interpreter

    # Interpret run block
    class Run < Component
      # Setup total time of final calculations
      # @param [Float] value the time value
      # @param [String] dimension of time value
      # @raise [Tools::Config::AlreadyDefined] if total time already defined
      def total_time(value, dimension = nil)
        Tools::Config.total_time(value, dimension)
      end
    end

  end
end
