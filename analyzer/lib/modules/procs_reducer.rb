module VersatileDiamond
  module Modules

    # Provides method for reducing proc objects
    module ProcsReducer
    private

      # Combines passed procs to one function
      # @param [Array] procs which will be combined
      # @yield returns heart of combination result
      # @return [Proc] the general function which contains calls of all other nested
      def reduce_procs(procs, &deepest_block)
        procs.reverse.reduce(deepest_block) do |acc, block|
          -> { block[&acc] }
        end
      end

    end
  end
end
