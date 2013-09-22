module VersatileDiamond
  module Concepts

    # Class for position instance. The position cannot be without face or
    # direction.
    class Position < Bond

      # When position is incomplete then raised it exception
      class Incomplete < Exception; end

      # Exception for position duplication case
      class Duplicate < Exception
        attr_reader :position
        def initialize(position); @position = position end
      end

      # Exception for case when linking atoms do not have a crystal lattice
      class UnspecifiedAtoms < Exception; end

      # The singleton method [] caches all instnaces and returns it if face and
      #   direction of the same.
      #
      # @option [Symbol] :face the face of position
      # @option [Symbol] :dir the direction of position
      # @raise [Incomplete] unless face or direction is nil
      # @return [Position] cached instance
      def self.[](face: nil, dir: nil)
        raise Incomplete unless face && dir
        super(face: face, dir: dir)
      end

      # Approximate compares two instances. If their fase and direction is
      # correspond then instances is the same.
      #
      # @param [Concepts::Bond] other an other comparing instances
      # @return [Boolean] same or not
      def same?(other)
        face == other.face && dir == other.dir
      end

      def to_s
        symbol = ':'
        "#{symbol}#{@face}#{symbol}#{@dir}#{symbol}#{symbol}"
      end
    end

  end
end
