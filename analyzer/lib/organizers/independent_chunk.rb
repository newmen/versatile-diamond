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
      extend Forwardable

      # Initializes independent chunk by typical reaction to it belongs and links of it
      # @param [DependentTypicalReaction] typical_reaction for which the new lateral
      #   reaction will be created later
      # @param [Set] targets of new chunk
      # @param [Hash] links of it chunk
      def initialize(typical_reaction, targets, links)
        super(targets, links)
        @typical_reaction = typical_reaction

        @_lateral_reaction, @_tail_name, @_total_links_num = nil
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
      def remember_internal_chunks!(_)
        # pass
      end

      # No parents no organization
      def reorganize_parents!(_)
        # pass
      end

      # Makes the lateral reaction which contain current chunk
      # @return [CombinedLateralReaction] instance of new lateral reaction
      def lateral_reaction
        return @_lateral_reaction if @_lateral_reaction

        full_rate = typical_reaction.full_rate
        @_lateral_reaction =
          CombinedLateralReaction.new(typical_reaction, self, full_rate)
      end

      # The chunk which created by chunk residual is not original
      # @return [Boolean] false
      def original?
        false
      end

      # Independent chunk is not original
      # @return [Boolean] false
      def deep_original?
        original?
      end

      def to_s
        "Independent chunk with #{tail_name}"
      end

    private

      attr_reader :typical_reaction

      # Gets the list of attributes which will passed to constructor of new instance
      # @param [Set] new_targets of creating instance
      # @param [Hasn] new_links of creating instance
      # @return [Array] the list of constructor arguments
      def replace_instance_args(new_targets, new_links)
        [typical_reaction, new_targets, new_links]
      end
    end

  end
end
