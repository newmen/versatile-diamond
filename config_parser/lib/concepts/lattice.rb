module VersatileDiamond
  module Concepts

    # Store lattice symbol as name and cpp class for generate corresponding
    # code
    class Lattice < Named
      extend Forwardable

      # @param [Symbol] symbol is lattice symbolic name
      # @param [String] klass for generating code
      def initialize(symbol, klass)
        super(symbol)
        @instance = Object.const_get(klass).new
      end

      def_delegator :@instance, :positions_between

      # Deligates calling to lattice instance
      # @param [Lattice] other an other concept of lattice
      # @param [Bond] relation the forward relation for which will be found
      #   opposite relation
      # @return [Bond] the reverse relation between two concepts of lattice
      def opposite_relation(other, relation)
        @instance.opposite_relation(other && other.instance, relation)
      end

    protected

      attr_reader :instance

    end

  end
end
