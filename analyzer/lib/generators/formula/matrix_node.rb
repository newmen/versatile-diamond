module VersatileDiamond
  module Generators
    module Formula

      class MatrixNode
        attr_reader :x, :y, :z, :atom

        def initialize(x, y, z, atom = nil)
          @x, @y, @z = x, y, z
          @atom = atom
        end

        # @return [Array]
        def coords
          [x, y, z]
        end

        # @param [Atom] atom
        # @return [MatrixNode]
        def place!(atom)
          @atom = atom
          self
        end

        # @return [NilClass]
        def reset!
          @atom = nil
        end
      end

    end
  end
end
