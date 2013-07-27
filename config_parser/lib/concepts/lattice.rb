module VersatileDiamond
  module Concepts

    # Store lattice symbol as name and cpp class for generate corresponding
    # code
    class Lattice < Base

      # @param [Symbol] symbol is lattice symbolic name
      # @param [String] cpp_class for generating code
      def initialize(symbol, cpp_class)
        super(symbol)
        @cpp_class = cpp_class
      end
    end

  end
end
