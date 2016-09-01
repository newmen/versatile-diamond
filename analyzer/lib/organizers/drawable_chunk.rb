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
      # @return [Symbol] same as #tail_name
      def name
        fixed_env_description = tail_name.gsub(' ', '_')
        :"__sub_chunk__with_#{fixed_env_description}"
      end
    end

  end
end
