module VersatileDiamond
  module Organizers

    # Describes the creating complex chunk
    class CombinedChunk < BaseChunk
      include ChunkParentsOrganizer
      include ChunksComparer
      include DrawableChunk
      include TailedChunk
      include TargetsProcessor

      # Constructs the combined chunk
      # @param [DependentTypicalReaction] typical_reaction for which the new lateral
      #   reaction will be created later
      # @param [Set] targets of new chunk
      # @param [Hash] links of new chunk
      # @param [Hash] variants is the full table of chunks combination variants for
      #   calculate maximal compatible full rate value
      def initialize(typical_reaction, targets, links, variants)
        super(targets, links)
        @typical_reaction = typical_reaction
        @variants = variants

        @_lateral_reaction, @_internal_chunks, @_tail_name, @_total_links_num = nil
      end

      # Makes the lateral reaction which contain current chunk
      # @return [CombinedLateralReaction] instance of new lateral reaction
      def lateral_reaction
        @_lateral_reaction ||=
          CombinedLateralReaction.new(typical_reaction, self, full_rate)
      end

      # Provides full rate of reaction which could be if lateral environment is same
      # as chunk describes
      #
      # @return [Float] the rate of reaction which use the current chunk
      def full_rate
        tf_rate = typical_reaction.full_rate
        max_prs = maximal_parents
        if max_prs.empty?
          tf_rate
        else
          # selecs maximal different rate
          max_prs.map(&:full_rate).max_by { |x| (tf_rate - x).abs }
        end
      end

      # The chunk which created by user described lateral reaction is original
      # @return [Boolean] true
      def original?
        false
      end

    private

      attr_reader :typical_reaction

      # Gets class of new replacing target instance
      # @return [Class] of new instance
      def replace_class
        CombinedChunk
      end

      # Gets the list of attributes which will passed to constructor of new instance
      # @param [Set] new_targets of creating instance
      # @param [Hasn] new_links of creating instance
      # @return [Array] the list of constructor arguments
      def replace_instance_args(new_targets, new_links)
        [typical_reaction, new_targets, new_links, @variants]
      end

      # Selects biggest original parents
      # @return [Array] the list of largest original parents
      def maximal_parents
        original_parents = parents.select(&:deep_original?)
        if original_parents.empty?
          []
        else
          max_num = original_parents.map(&:total_links_num).max
          original_parents.select { |pr| pr.total_links_num == max_num }
        end
      end
    end

  end
end
