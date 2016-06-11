module VersatileDiamond
  module Concepts

    # Class for multibond instance. The multibond can only be amorphous.
    class MultiBond

      class << self
        # The singleton method [] caches all instnaces and returns it if arity is same
        # @param [Integer] arity of creating bond
        # @return [MultiBond] cached instance
        def [](arity)
          @consts ||= {}
          @consts[arity] ||= new(arity)
        end
      end

      attr_reader :arity

      # Creates a multibond instance by arity
      # @param [Integer] arity of creating bond
      def initialize(arity)
        if arity < 2 || arity > 3
          raise 'Wrong arity'
        else
          @arity = arity
        end
      end

      # Compares two instances
      # @param [MultiBond] other relation instance with which comparing will be
      # @return [Boolean] equal or not
      def ==(other)
        self.class == other.class && self.arity == other.arity
      end

      # Checks that current multibond is really bond
      # @return [Boolean] true
      def bond?
        true
      end

      # Checks that current multibond is really multi
      # @return [Boolean] true
      def multi?
        true
      end

      # Checks that current instance is really relation
      # @return [Boolean] true
      def relation?
        true
      end

      # Checks that current multibond belongs to crystal
      # @return [Boolean] is have face and direction or not
      def belongs_to_crystal?
        false
      end

      # Multibond instance aways is exist
      # @return [Boolean] true
      def exist?
        true
      end

      def inspect
        arity == 2 ? '==' : '≡≡'
      end

    private

      # Provides comparing core for multibond instances
      # @param [MultiBond] other comparing instance
      # @return [Integer] the comparing result
      def comparing_core(other)
        order(self, other, :arity)
      end
    end

  end
end
