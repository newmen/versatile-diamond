module VersatileDiamond
  module Organizers

    # Provides method which could be used for draw chunk on graph diagram
    module DrawableChunk
      # Gets the list of specs from which depends the current chunk
      # @return [Array] the list of using specs
      def specs
        (links.keys - targets.to_a).map(&:first).uniq
      end

      # Gets the name of chunk
      # @return [String] same as #tail_name
      def name
        tail_name.freeze
      end
    end

  end
end
