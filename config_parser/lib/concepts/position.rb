module VersatileDiamond
  module Concepts

    # Class for position instance. The position cannot be without face or
    # direction.
    class Position < Bond
      class IncompleteError < Exception; end

      # The singleton method [] caches all instnaces and returns it if face and
      #   direction of the same.
      #
      # @option [Symbol] :face the face of position
      # @option [Symbol] :dir the direction of position
      # @return [Position] cached instance
      def self.[](face: nil, dir: nil)
        raise IncompleteError unless face && dir
        super(face: face, dir: dir)
      end

      # def same?(other)
      #   face == other.face && dir == other.dir
      # end

      def to_s
        symbol = ':'
        "#{symbol}#{@face}#{symbol}#{@dir}#{symbol}#{symbol}"
      end
    end

  end
end
