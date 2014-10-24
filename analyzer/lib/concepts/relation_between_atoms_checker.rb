module VersatileDiamond
  module Concepts

    # Provides method for find relation between two atoms
    module RelationBetweenAtomsChecker
      # Gets relation between apssed atom
      # @param [Atom] first atom
      # @param [Atom] second atom
      # @return [Bond] relation between atoms or nil if relation is not presented
      def relation_between(first, second)
        rels = links[first]
        pair = rels.find { |atom, _| atom == second } if rels
        pair && pair.last
      end
    end

  end
end
