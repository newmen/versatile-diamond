module VersatileDiamond
  module Concepts

    # Provides methods for linking two surface atoms
    module SurfaceLinker
    protected

      # Links together atoms of surface spec. Surface spec must have at least
      # one atom belonging to the lattice. Obtaining the inverse relation
      # between linking atoms is occured by the crystal lattice.
      #
      # @param [Atom] first the first of two linking atoms
      # @param [Atom] second the second of two linking atoms
      # @param [Bond] relation the instance of relation
      # @option [Boolean] :check_possible is flag that another positions should be
      #   checked
      # @raise [Lattices::Base::UndefinedRelation] if used relation instance is
      #   wrong for current lattice
      # @raise [Position::Duplicate] if same position already exist
      def link_together(first, second, relation, check_possible: true)
        orel = opposite_relation(first, second, relation)

        if !relation.bond? && has_relations?(first, second, relation, orel)
          raise Position::Duplicate, relation
        end

        if check_possible && !(relation.exist? || position_presented?)
          raise NonPosition::Impossible
        end

        link_with_other(first, second, relation, orel)
      end

    private

      # Checks that any position relation is presented
      # @return [Boolean] is position presented in links graph or not
      def position_presented?
        links.any? do |_, rels|
          rels.any? { |_, r| r.relation? && !r.bond? && r.exist? }
        end
      end

      # If so, must have relations in both directions
      # @param [Atom] first the first atom
      # @param [Atom] second the second atom
      # @param [Array] relations the array with two relations
      # @return [Boolean] has or not
      def has_relations?(first, second, *relations)
        a = has_relation?(first, second, relations.first)
        b = has_relation?(second, first, relations.last)

        if a && b
          true
        elsif a || b
          raise 'Checking relations ERROR'
        else
          false
        end
      end

      # Check availability of passed relation between atoms
      # @param [Atom] first the first atom
      # @param [Atom] second the second atom
      # @param [Bond] relation the relation from first atom to second atom
      # @return [Boolean] has or not
      def has_relation?(first, second, relation)
        !!links[first].find do |atom, link|
          atom == second && link.it?(relation.params)
        end
      end
    end

  end
end
