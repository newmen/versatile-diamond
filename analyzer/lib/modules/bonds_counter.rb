module VersatileDiamond
  module Modules

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

      # Counts external bonds of passed atoms
      # @param [Array] atoms which external bonds will be counted
      # @return [Integer] the number of total external bonds
      def count_external_bonds_of(atoms)
        atoms.reduce(0) { |acc, atom| acc + external_bonds_for(atom) }
      end
    end
  end
end
