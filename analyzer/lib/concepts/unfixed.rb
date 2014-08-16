module VersatileDiamond
  module Concepts

    # The unfixed property
    class Unfixed < RelativeProperty
      # Applies unfixed state to passed atom
      # @param [SpecificAtom] atom which state will be changed
      def apply_to(atom)
        raise 'Latticed atom could not be unfxied' if atom.lattice
        atom.unfixed!
      end

      def to_s
        'u'
      end
    end

  end
end
