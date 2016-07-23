module VersatileDiamond
  module Concepts

    # Provides method for swapping atoms in links graph
    module AtomsSwapper
      # Swaps atoms in passed links graph
      # @param [Hash] links where atoms will be swapped
      # @param [Atom | AtomRelation | SpecificAtom] from which swapping will be done
      # @param [Atom | AtomRelation | SpecificAtom] to which swapping will be done
      def swap_atoms_in!(links, from, to)
        rels = links[to] = links.delete(from)
        rels.each do |atom, _|
          links[atom].map! { |a, rel| [(a == from ? to : a), rel] }
        end
      end
    end

  end
end
