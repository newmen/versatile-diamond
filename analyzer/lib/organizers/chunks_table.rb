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
    end

  end
end
