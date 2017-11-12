module VersatileDiamond
  module Generators
    module Formula

      class MatrixNode
        attr_reader :x, :y, :z, :atom

        def initialize(x, y, z, atom = nil)
          @x, @y, @z = x, y, z
          @atom = atom
        end
      end

    end
  end
end
