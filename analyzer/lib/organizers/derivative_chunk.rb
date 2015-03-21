module VersatileDiamond
  module Organizers

    # Describes the chunk which constructs from another chunks and can builds lateral
    # reaction for which it was builded
    class DerivativeChunk < ChunkCore
      # Constructs the chunk by another chunks
      # @param [DependentTypicalReaction] typical_reaction by which the lateral
      #   reaction will be combined
      # @param [Array] chunks the parents of building chunk
      def initialize(typical_reaction, chunks)
        super(chunks)
        chunks.each { |ch| store_parent(ch) }
        @typical_reaction = typical_reaction

        @_lateral_reaction, @_full_rate, @_tail_name = nil
      end

      # Makes the lateral reaction which contain current chunk
      # @return [CombinedLateralReaction] instance of new lateral reaction
      def lateral_reaction
        @_lateral_reaction ||= CombinedLateralReaction.new(@typical_reaction, self)
      end

      # Provides full rate of reaction which could be if lateral environment is same
      # as chunk describes
      #
      # @return [Float] the rate of reaction which use the current chunk
      def full_rate
        @_full_rate ||= parents.uniq.map(&:full_rate).max
      end

      # Collecs all names from parent chunks and joins it by 'and' string
      # @return [String] the combined name by names of there objects from parent chunks
      def tail_name
        @_tail_name ||= parents.map(&:tail_name).join(' and ')
      end
    end

  end
end
