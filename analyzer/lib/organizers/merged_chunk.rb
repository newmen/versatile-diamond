module VersatileDiamond
  module Organizers

    # Describes the chunk which constructs from another chunks and can builds lateral
    # reaction for which it was builded
    class MergedChunk < BaseChunk
      include Modules::ExtendedCombinator
      include Modules::ListsComparer
      include ChunkParentsOrganizer
      include ChunksComparer
      include DrawableChunk
      include TailedChunk
      include TargetsProcessor

      attr_reader :parents, :links, :targets

      # Constructs the chunk by another chunks
      # @param [DependentTypicalReaction] typical_reaction for which the new lateral
      #   reaction will be created later
      # @param [Array] chunks the parents of building chunk
      # @param [Hash] variants is the full table of chunks combination variants for
      #   calculate maximal compatible full rate value
      def initialize(typical_reaction, chunks, variants)
        super()

        @typical_reaction = typical_reaction

        raise 'Merged chunk should have more that one parent' if chunks.size < 2
        @parents = chunks
        @variants = variants

        @targets = merge_targets(chunks)
        @links = merge_links(chunks)

        @_lateral_reaction, @_internal_chunks, @_tail_name = nil
      end

      # Makes the lateral reaction which contain current chunk
      # @return [CombinedLateralReaction] instance of new lateral reaction
      def lateral_reaction
        @_lateral_reaction ||=
          CombinedLateralReaction.new(typical_reaction, self, full_rate)
      end

      # The chunk which created by user described lateral reaction is original
      # @return [Boolean] true
      def original?
        false
      end

      def to_s
        "Merged chunk with #{tail_name}"
      end

      def inspect
        "#{to_s} #{object_id}"
      end

    private

      attr_reader :typical_reaction

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

      # Provides full rate of reaction which could be if lateral environment is same
      # as chunk describes
      #
      # @return [Float] the rate of reaction which use the current chunk
      def full_rate
        tf_rate = typical_reaction.full_rate
        max_prs = maximal_parents
        if max_prs.size == 1
          max_prs.first.full_rate
        else
          all_possible_combinations(max_prs).reverse.each do |slice|
            rates = slice.map do |cs|
              value = @variants[Multiset.new(cs)]
              value && value.original? && value.full_rate
            end

            good_rates = rates.select { |x| x }
            # selecs maximal different rate
            return good_rates.max_by { |x| (tf_rate - x).abs } unless good_rates.empty?
          end

          tf_rate
        end
      end

      # Selects biggest original parents
      # @return [Array] the list of largest original parents
      def maximal_parents
        original_parents = parents.select(&:original?)
        max_num = original_parents.map(&:total_links_num).max
        original_parents.select { |pr| pr.total_links_num == max_num }
      end

      # Gets all possible combinations of array items
      # @param [Array] array which items will be combinated
      # @return [Array] the list of all posible combinations
      def all_possible_combinations(array)
        sliced_combinations(array, 1).map(&:uniq)
      end
    end

  end
end
