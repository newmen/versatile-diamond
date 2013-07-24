module VersatileDiamond

  module Concepts

    # Store lattice symbol and cpp class for generate corresponding code
    class Lattice

      # @param [Symbol] symbol is lattice symbolic name
      # @param [String] cpp_class for generating code
      def initialize(symbol, cpp_class)
        @symbol, @cpp_class = symbol, cpp_class
      end

      def to_s
        @symbol.to_s
      end
    end

  end

end
