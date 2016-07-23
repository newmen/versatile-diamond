module VersatileDiamond
  module Concepts

    # Class for bond instance. The bond can be without face and direction.
    class Bond
      include BondsOrderer

      AMORPH_PARAMS = { face: nil, dir: nil }.freeze

      attr_reader :face, :dir

      class << self
        # The singleton method [] caches all instnaces and returns it if face
        # and direction of the same.
        #
        # @option [Symbol] :face the face of bond
        # @option [Symbol] :dir the direction of bond
        # @return [Bond] cached instance
        def [](face: nil, dir: nil)
          key = face.to_s
          key << "_#{dir}" if dir
          @consts ||= {}
          @consts[key] ||= new(face, dir)
        end

        # Gets an amorph bond
        # @param [Bond] the amorph bond
        def amorph
          self[AMORPH_PARAMS]
        end

        # Resets internal cache for RSpec
        def reset
          @consts = nil
        end
      end

      # Store the face and dir for instance
      # @param [Symbol] face the face of bond
      # @param [Symbol] dir the direction of bond
      def initialize(face, dir)
        @face, @dir = face, dir && dir.to_sym
      end

      # Compares two instances
      # @param [Bond] other relation instance with which comparing will be
      # @return [Boolean] equal or not
      def ==(other)
        self.class == other.class && other.it?(params)
      end

      # @return [Integer]
      def arity
        1
      end

      # Makes cross instance of current
      # @return [Bond] the instance with cross direction
      def cross
        self.class[face: face, dir: (dir == :front ? :cross : :front)]
      end

      # Gets parameters of relation
      # @return [Hash] the hash of relation perameters
      def params
        { face: face, dir: dir }
      end

      # Makes position relation from bond relation
      # @return [Position] the position which correspond to current bond
      def make_position
        Position[params]
      end

      # Checks current instances for passed options
      # @option [Symbol] :face the face of instance
      # @option [Symbol] :dir the direction of instance
      # @return [Boolean] it or not
      def it?(face: nil, dir: nil)
        @face == face && @dir == dir
      end

      # Approximate compares two instances. If their classes is same then
      # instances is the same. Else delegate comparing to other instance.
      #
      # @param [Concepts::Bond] other an other comparing instances
      # @return [Boolean] same or not
      def same?(other)
        self.class == other.class || other.same?(self)
      end

      # Checks that current bond is really bond
      # @return [Boolean] true
      def bond?
        true
      end

      # Checks that current bond is really multi
      # @return [Boolean] false
      def multi?
        false
      end

      # Checks that current instance is really relation
      # @return [Boolean] true
      def relation?
        true
      end

      # Checks that current bond belongs to crystal
      # @return [Boolean] is have face and direction or not
      def belongs_to_crystal?
        face && dir
      end

      # Bond instance aways is exist
      # @return [Boolean] true
      def exist?
        true
      end

      def to_s
        symbol = '-'
        str = symbol.dup
        str << "#{face}#{symbol}" if face
        str << "#{dir}#{symbol}" if dir
        "#{str}#{symbol}"
      end

      def inspect
        to_s
      end

    private

      # Provides comparing core for directed instances
      # @param [Bond] other comparing instance
      # @return [Integer] the comparing result
      def comparing_core(other)
        if belongs_to_crystal? && other.belongs_to_crystal?
          order(other, self, :face) do
            order(other, self, :dir)
          end
        elsif belongs_to_crystal?
          -1
        else # other.belongs_to_crystal?
          1
        end
      end
    end

  end
end
