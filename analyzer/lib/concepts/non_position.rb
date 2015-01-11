module VersatileDiamond
  module Concepts

    # Class for not position instance. If this instance between two atoms then no any
    # relations between them could be
    class NonPosition < Position

      # When another positions isn't presented
      class Impossible < Errors::Base; end

      # Gets self instance
      # @return [NonPosition] the non position relation
      def make_position
        self
      end

      # Non position instance aways isn't exist
      # @return [Boolean] false
      def exist?
        false
      end

      def to_s
        symbol = '$'
        "#{symbol}#{@face}#{symbol}#{@dir}#{symbol}#{symbol}"
      end
    end

  end
end
