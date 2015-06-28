module VersatileDiamond
  module Organizers

    # Provides method for merge targets of chunks
    class ChunkTargetsMerger
      # Gets set of targets from all passed containers
      # @param [Array] chunks the list of chunks which targets will be merged
      # @return [Set] the set of targets of internal chunks
      def merge(chunks)
        chunks.map { |chunk| chunk.mapped_targets.values.to_set }.reduce(:+)
      end
    end

  end
end
