module VersatileDiamond
  module Concepts

    # Provides methods for linking two atoms
    module Linker

      # Exception for case when linking same atom
      class SameAtom < Errors::Base; end

    private

      # Links two atoms in both directions
      # @param [Atom] first the first atom
      # @param [Atom] second the second atom
      # @param [Bond] link the relation from first to second
      # @param [Bond] opposite_link the relation from second to first
      # @raise [SameAtom] if first is same atom as well as second
      def link_with_other(first, second, link, opposite_link)
        raise SameAtom if first == second
        @links[first] << [second, link]
        @links[second] << [first, opposite_link]
      end
    end

  end
end
