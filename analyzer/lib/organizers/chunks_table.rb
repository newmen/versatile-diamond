module VersatileDiamond
  module Organizers

    # Represent the table of dynamic programming for organization of dependencies
    # between chunks of lateral reactions
    class ChunksTable < DpTable
    private

      # Gets the empty residual for passed chunk
      # @param [Chunk] chunk for which the empty residual will be gotten
      # @return [ChunkResidual] the empty residual for passed chunk
      def empty_residual(chunk)
        ChunkResidual.empty(chunk)
      end

      # Also checks that instances are belongs to same class
      # @param [MinuendChunk] one is the first comparing chunk
      # @param [MinuendChunk] two is the second comparing chunk
      # @return [Boolean] are equal passed instances or not
      # @override
      def same?(one, two)
        one.class == two.class && super
      end
    end

  end
end
