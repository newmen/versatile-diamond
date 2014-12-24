module VersatileDiamond
  module Concepts

    # Represents gas spec
    class GasSpec < Spec

      # Returns that spec is gas
      # @return [Boolean] gas or not
      def gas?
        true
      end

    private

      # Links together atoms of gas spec. Gas spec could have only free bonds
      # and could'n have positions between atoms.
      #
      # @param [Atom] first the first linking atom
      # @param [Atom] second the second linking atom
      # @param [Bond] relation the used bond for linking
      # @raise [Lattices::Base::UndefinedRelation] if relation isn't free
      def link_together(first, second, relation)
        if relation.belongs_to_crystal?
          raise Lattices::Base::UndefinedRelation.new(relation)
        end

        link_with_other(first, second, relation, relation)
      end
    end

  end
end
