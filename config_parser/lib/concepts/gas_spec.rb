module VersatileDiamond
  module Concepts

    # Represents gas spec
    class GasSpec < Spec

      # Returns that spec is gas
      # @return [Boolean] gas or not
      def is_gas?
        true
      end

    private

      # Links together atoms of gas spec. Gas spec could have only free bonds
      # and could'n have positions between atoms.
      #
      # @param [Atom] first the first linking atom
      # @param [Atom] second the second linking atom
      # @param [Bond] bond the used bond for linking
      # @raise [Lattices::Base::WrongRelation] if bond isn't free
      def link_together(first, second, bond)
        unless bond.class == Bond && bond.face.nil?
          raise Lattices::Base::WrongRelation.new(bond)
        end

        @links[first] << [second, bond]
        @links[second] << [first, bond]
      end
    end

  end
end
