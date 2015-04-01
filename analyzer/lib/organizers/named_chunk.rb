module VersatileDiamond
  module Organizers

    # Provides common methods for original chunk classes
    module NamedChunk
      # Collecs all names from there objects and joins it by 'and' string
      # @return [String] the combined name by names of there objects
      def tail_name
        @_tail_name ||= tail_names.join(' and ')
      end
    end

  end
end
