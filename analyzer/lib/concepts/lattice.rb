module VersatileDiamond
  module Concepts

    # Store lattice symbol as name and cpp class for generate corresponding
    # code
    class Lattice < Named
      extend Forwardable

      attr_reader :klass, :instance

      # @param [Symbol] symbol is lattice symbolic name
      # @param [String] klass for generating code
      def initialize(symbol, klass)
        super(symbol)
        @klass = klass
        @instance = Object.const_get(klass).new
      end

      def_delegator :@instance, :positions_between

      # Compares two lattice instances
      # @param [Latice] other the comparable lattice
      # @return [Boolean] are equal or not
      def == (other)
        other && klass == other.klass
      end

      # Delegates calling to lattice instance
      # @param [Lattice] other an other concept of lattice
      # @param [Bond] relation the forward relation for which will be found
      #   opposite relation
      # @return [Bond] the reverse relation between two concepts of lattice
      def opposite_relation(other, relation)
        @instance.opposite_relation(other && other.instance, relation)
      end

      def to_s
        "%#{name}"
      end

      def inspect
        to_s
      end
    end

  end
end
