module VersatileDiamond
  module Lattices

    # The base class for lattice instanes
    # @abstract
    class Base

      # Exception class for case when used bond is incorrect
      class WrongRelation < Exception
        attr_reader :relation
        def initialize(relation); @relation = relation end
      end

      # Checks other lattice and gives an edge corresponding to inverse
      # relation between atoms in the lattice
      #
      # @param [Base] other the lattice of another atom
      # @param [Concepts::Bond] edge the relation between current atom and
      #   another atom
      # @raise [WrongRelation] if edge is invalid
      # @return [Concepts::Bond] then inverse relation between atoms in lattice
      def opposite_edge(other, edge)
        if self.class == other.class
          same_lattice(edge)
        else
          other_lattice(edge)
        end
      end
    end

  end
end
