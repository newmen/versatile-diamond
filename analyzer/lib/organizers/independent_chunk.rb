module VersatileDiamond
  module Organizers

    # Describes the chunk which rest after difference operation and another smallest
    # chunks which contains in it is not presented
    class IndependentChunk < BaseChunk
      include Modules::ListsComparer
      include MinuendChunk
      include DrawableChunk
      include ChunksComparer
      include TailedChunk
      include TargetsProcessor
      extend Forwardable

      attr_reader :links, :targets

      # Initializes independent chunk by typical reaction to it belongs and links of it
      # @param [Chunk] owner which is original big chunk
      # @param [Set] targets of new chunk
      # @param [Hash] links of it chunk
      def initialize(owner, targets, links)
        super()

        @owner = owner
        @targets = targets
        @links = links

        @_lateral_reaction, @_tail_name = nil
      end

      # The independent chunk haven't parents
      # @return [Array] the empty array
      def parents
        []
      end

      # Independent chunk is always source chunk
      # @return [Array] list with one self item
      def internal_chunks
        [self]
      end

      # Nothing to remember
      def remember_internal_chunks!
        # pass
      end

      # No parents no organization
      def reorganize_parents!(_)
        # pass
      end

      # Makes the lateral reaction which contain current chunk
      # @return [CombinedLateralReaction] instance of new lateral reaction
      def lateral_reaction
        @_lateral_reaction ||= CombinedLateralReaction.new(
                                    typical_reaction, self, typical_reaction.full_rate)
      end

      # The chunk which created by chunk residual is not original
      # @return [Boolean] false
      def original?
        false
      end

      def to_s
        "Independent chunk with #{tail_name}"
      end

      def inspect
        "#{to_s} #{object_id}"
      end

    private

      def_delegator :@owner, :typical_reaction

    end

  end
end
