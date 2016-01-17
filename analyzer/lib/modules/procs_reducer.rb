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

      # Collects procs which nests each other, after than calls combined procedure
      # @param [Proc] deepest_block the block for the deepest call
      # @yield [Symbol, Array, Hash] nests the some method call
      # @return [Object] the result of deepest block call
      def inlay_procs(deepest_block, &block)
        procs = []
        nest = -> method_name, *args, **kwargs do
          procs <<
            if kwargs.empty?
              -> &prc { send(method_name, *args, &prc) }
            else
              -> &prc { send(method_name, *args, **kwargs, &prc) }
            end
        end

        block[nest]
        reduce_procs(procs, &deepest_block).call
      end
    end

  end
end
