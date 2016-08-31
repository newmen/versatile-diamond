module VersatileDiamond
  module Concepts

    # Uses for replasing similar atoms in concept specs
    class VeiledAtom < VeiledInstance
      binary_operations :original_same?, :accurate_same?
    end

  end
end
