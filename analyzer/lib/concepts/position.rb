module VersatileDiamond
  module Concepts

    # Class for position instance. The position cannot be without face or
    # direction.
    class Position < Bond

      # When position is incomplete then raised it exception
      class Incomplete < Errors::Base; end

      # Exception for position duplication case
      class Duplicate < Errors::Base
        attr_reader :position
        def initialize(position); @position = position end
      end

      # Exception for case when linking atoms do not have a crystal lattice
      class UnspecifiedAtoms < Errors::Base; end

      class << self
        # The singleton method [] caches all instnaces and returns it if face
        # and direction of the same.
        #
        # @option [Symbol] :face the face of position
        # @option [Symbol] :dir the direction of position
        # @raise [Incomplete] unless face or direction is nil
        # @return [Position] cached instance
        def [](face: nil, dir: nil)
          raise Incomplete unless face && dir
          super(face: face, dir: dir)
        end

        # Makes a new position from relation
        # @param [Bond] relation the relation from which position will be maked
        # @return [Position] a position with same face and dir as relation
        def make_from(relation)
          self[relation.params]
        end
      end

      # Approximate compares two instances. If their face and direction is
      # correspond then instances is the same.
      #
      # @param [Concepts::Bond] other an other comparing instances
      # @return [Boolean] same or not
      def same?(other)
        exist? == other.exist? && face == other.face && dir == other.dir
      end

      # Checks that current position is not a bond
      # @return [Boolean] false
      def bond?
        false
      end

      # Position always belongs to crystal
      # @return [Boolean] true
      def belongs_to_crystal?
        true
      end

      def to_s
        symbol = ':'
        "#{symbol}#{@face}#{symbol}#{@dir}#{symbol}#{symbol}"
      end
    end

  end
end
