module VersatileDiamond
  module Concepts

    # Store lattice symbol as name and cpp class for generate corresponding
    # code
    class Lattice < Named

      # @param [Symbol] symbol is lattice symbolic name
      # @param [String] klass for generating code
      def initialize(symbol, klass)
        super(symbol)
        @klass = Object.const_get(klass).new
      end

      # Deligates calling to lattice instance
      # @param [Lattice] other an other concept of lattice
      # @return [Bond] the reverse relation between two concepts of lattice
      def opposite_edge(other, edge)
        @klass.opposite_edge(other && other.klass, edge)
      end

      def positions_to(*args)
        @klass.positions_to(*args)
      end

    protected

      attr_reader :klass

    end

  end
end
