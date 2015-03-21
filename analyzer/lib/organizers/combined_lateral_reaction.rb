module VersatileDiamond
  module Organizers

    # Describes lateral reaction which creates by chunks combinations
    class CombinedLateralReaction
      include LateralReactionInstance
      include MultiParentsAndChildren
      extend Forwardable

      def_delegator :chunk, :full_rate
      attr_reader :chunk

      # Initializes combined lateral reaction
      # @param [DependentTypicalReaction] typical_reaction to which will be redirected
      #   calls for get source species and etc.
      # @param [DerivativeChunk] chunk which describes local environment of combined
      #   lateral reaction
      def initialize(typical_reaction, chunk, tail_name)
        @typical_reaction = typical_reaction
        @chunk = chunk
      end

      # Gets the name of lateral reaction
      # @return [String] the name of lateral reaction
      def name
        "#{@typical_reaction.name} #{chunk.tail_name}"
      end

      def formula
        "#{@typical_reaction.formula} | ..."
      end
    end

  end
end
