module VersatileDiamond
  module Concepts

    # Class for not position instance. If this instance between two atoms then no any
    # relations between them could be
    class NonPosition < Position

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
