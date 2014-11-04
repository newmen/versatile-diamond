module VersatileDiamond
  module Concepts

    # Provides methods for linking two surface atoms
    module SurfaceLinker

      # Exception for case when linking same atom
      class SameAtom < Errors::Base; end

    protected

      # Links together atoms of surface spec. Surface spec must have at least
      # one atom belonging to the lattice. Obtaining the inverse relation
      # between linking atoms is occured by the crystal lattice.
      #
      # @param [Atom] first the first of two linking atoms
      # @param [Atom] second the second of two linking atoms
      # @param [Bond] relation the instance of relation
      # @raise [Lattices::Base::UndefinedRelation] if used relation instance is
      #   wrong for current lattice
      # @raise [Position::Duplicate] if same position already exist
      def link_together(first, second, relation)
        orel = opposite_relation(first, second, relation)

        if !relation.bond? && has_positions?(first, second, relation, orel)
          raise Position::Duplicate, relation
        end

        link_with_other(first, second, relation, orel)
      end

    private

      # If so, must have relations in both directions
      # @param [Atom] first the first atom
      # @param [Atom] second the second atom
      # @param [Array] positions the array with two positions
      # @return [Boolean] has or not
      def has_positions?(first, second, *positions)
        a = has_relation?(first, second, positions.first)
        b = has_relation?(second, first, positions.last)

        if a && b
          true
        elsif a || b
          raise 'Checking positions ERROR'
        else
          false
        end
      end
    end

  end
end
