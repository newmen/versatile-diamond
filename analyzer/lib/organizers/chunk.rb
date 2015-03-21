module VersatileDiamond
  module Organizers

    # Provides logic for side-chunk of lateral reaction
    class Chunk < ChunkCore
      include MinuendChunk
      extend Forwardable

      def_delegator :lateral_reaction, :full_rate
      attr_reader :lateral_reaction

      # Initializes the chunk by lateral reaction and it there objects
      # @param [DependentLateralReaction] lateral_reaction link to which will be
      #   remembered
      # @param [Array] theres the array of there objects the links from which will be
      #   collected and used as links of chunk
      def initialize(lateral_reaction, theres)
        super(theres)
        @theres = theres
        @lateral_reaction = lateral_reaction

        @_tail_name = nil
      end

      # Collecs all names from there objects and joins it by 'and' string
      # @return [String] the combined name by names of there objects
      def tail_name
        @_tail_name ||= @theres.map(&:description).join(' and ')
      end

    private

      # Provides the lowest level of comparing two minuend instances
      # @param [MinuendChunk] other comparing instance
      # @return [Proc] the core of comparison
      def comparing_core(other)
        if self.class == other.class
          -> { 0 }
        else
          -> { -1 }
        end
      end

      # Gets the self instance
      # @return [Chunk] self
      def owner
        self
      end
    end

  end
end
