module VersatileDiamond
  module Mcs

    # Provides functionality for wrap the links graph. Instances of it class can be
    # compare between each other by Hanser's recursive algorithm
    class LinksWrapper
      attr_reader :links

      # Initializes wrapper by wrapping links
      # @param [Hash] links which should be wrapped
      def initialize(links)
        @links = links
      end
    end

  end
end
