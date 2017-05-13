module VersatileDiamond
  module Concepts

    # Uses for replasing similar atoms in concept specs
    class VeiledAtom < VeiledInstance
      delegate :lattice, :valence, :original_valence, :relevants, :relations_limits
      delegate :original_same?, :accurate_same?
    end

  end
end
