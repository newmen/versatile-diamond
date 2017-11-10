module VersatileDiamond
  module Organizers

    # Provides logic for typical chunk with replaced target
    class TargetReplacedChunk < TypicalChunk

      # Initializes the typical chunk with replaced target
      # @param [DependentLateralReaction] lateral_reaction which will be prototype of
      #   internal lateral reaction
      # @param [Set] targets of new chunk
      # @param [Hash] links of new chunk
      # @param [String] tail_name of new chunk
      def initialize(lateral_reaction, targets, links, tail_name)
        super(combine_lateral_reaction(lateral_reaction), targets, links, tail_name)
      end

      # The target replaced chunk is not original
      # @return [Boolean] false
      def original?
        false
      end

    private

      # Creates lateral reaction which will be stored in current chunk
      # @param [DependentLateralReaction] lateral_reaction which will be prototype of
      #   internal lateral reaction
      # @return [CombinedLateralReaction] new lateral reaction
      def combine_lateral_reaction(lateral_reaction)
        typical_reaction = lateral_reaction.parent
        full_rate = lateral_reaction.full_rate
        rate_tuple = lateral_reaction.rate_tuple
        CombinedLateralReaction.new(typical_reaction, self, full_rate, rate_tuple)
      end
    end

  end
end
