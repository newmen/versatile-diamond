module VersatileDiamond
  module Organizers

    # Describes the creating complex chunk
    class CombinedChunk < BaseChunk
      include Modules::ExtendedCombinator
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

      def inspect
        "#{to_s} #{object_id}"
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
