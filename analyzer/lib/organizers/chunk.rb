module VersatileDiamond
  module Organizers

    # Provides logic for side-chunk of lateral reaction
    class Chunk
      # Initializes the chunk by lateral reaction and it there objects
      # @param [DependentLateralReaction] lateral_reaction link to which will be
      #   remembered
      # @param [Array] theres the array of there objects the links from which will be
      #   collected and used as links of chunk
      def initialize(lateral_reaction, theres)
        @lateral_reaction = lateral_reaction
        @links = merge_there_links(theres)
      end

    private

      # Merges the links of there objects
      # @param [Array] theres array of there objects the links of which will be merged
      # @return [Hash] the common links hash
      def merge_there_links(theres)
        theres.each_with_object({}) do |there, acc|
          there.links.each do |sa1, rels|
            acc[sa1] ||= []
            acc[sa1] += rels
          end
        end
      end
    end

  end
end
