module VersatileDiamond
  module Concepts

    # Provides methods for count number of bonds for concrete atom
    module BondsCounter

      # Counts external bonds for atom
      # @param [Concepts::Atom | Concepts::AtomReference] atom the atom for wtich need
      #   to count bonds
      # @return [Integer] number of bonds
      def external_bonds_for(atom)
        atom.valence - internal_bonds_for(atom)
      end

    protected

      # Counts internal bonds for atom
      # @param [Concepts::Atom | Concepts::AtomReference] atom the atom for wtich need
      #   to count bonds
      # @return [Integer] number of bonds
      def internal_bonds_for(atom)
        links[atom].map(&:last).select(&:bond?).size
      end
    end
  end
end
