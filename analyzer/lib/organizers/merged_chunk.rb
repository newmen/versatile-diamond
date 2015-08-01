module VersatileDiamond
  module Organizers

    # Describes the chunk which constructs from another chunks and can builds lateral
    # reaction for which it was builded
    class MergedChunk < CombinedChunk

      attr_reader :parents

      # Constructs the chunk by another chunks
      # @param [DependentTypicalReaction] typical_reaction for which the new lateral
      #   reaction will be created later
      # @param [Array] chunks the parents of building chunk
      # @param [Hash] variants is the full table of chunks combination variants for
      #   calculate maximal compatible full rate value
      def initialize(typical_reaction, chunks, variants)
        raise 'Merged chunk should have more that one parent' if chunks.size < 2

        super(typical_reaction, merge_targets(chunks), merge_links(chunks), variants)
        @parents = chunks

        @_lateral_reaction, @_internal_chunks, @_tail_name, @_total_links_num = nil
      end

      def to_s
        "Merged chunk with #{tail_name}"
      end

    private

      # Gets set of targets from all passed containers
      # @param [Array] chunks the list of chunks which targets will be merged
      # @return [Set] the set of targets of internal chunks
      def merge_targets(chunks)
        ChunkTargetsMerger.new.merge(chunks)
      end

      # Merges all links from chunks list
      # @param [Array] chunks which links will be merged
      # @return [Hash] the common links hash
      def merge_links(chunks)
        clm = ChunkLinksMerger.new
        chunks.reduce({}, &clm.public_method(:merge))
      end
    end

  end
end
