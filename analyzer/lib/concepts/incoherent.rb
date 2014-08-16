module VersatileDiamond
  module Concepts

    # The incoherent property
    class Incoherent < RelativeProperty
      # Applies incoherent state to passed atom
      # @param [SpecificAtom] atom which state will be changed
      def apply_to(atom)
        atom.incoherent!
      end

      def to_s
        'i'
      end
    end

  end
end
