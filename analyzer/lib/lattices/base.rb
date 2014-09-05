module VersatileDiamond
  module Lattices

    # The base class for lattice instanes
    # @abstract
    class Base
      include BasicRelations

      # Exception class for case when used bond is incorrect
      class UndefinedRelation < Errors::Base
        attr_reader :relation
        def initialize(relation); @relation = relation end
      end

      class << self
        # Gets a limit for amorph relation
        # @return [Hash] the hash where key is hash of amorph bond properties and value
        #   is a limit of relations number
        def amorph_relations_limit
          { Concepts::Bond::AMORPH_PROPS => 1 }
        end
      end

      # Checks other lattice and gives an edge corresponding to inverse
      # relation between atoms in the lattice
      #
      # @param [Base] other the lattice of another atom
      # @param [Concepts::Bond] relation the relation between current atom and
      #   another atom
      # @raise [UndefinedRelation] if relation is invalid
      # @return [Concepts::Bond] then inverse relation between atoms in lattice
      def opposite_relation(other, relation)
        if self.class == other.class
          same_lattice(relation)
        elsif !relation.belongs_to_crystal?
          relation # there relation is a bond without face and direction
        else
          other_lattice(relation)
        end
      end

      # Finds position relations between passed in crystal lattice limited by
      # relations container
      #
      # @param [Atom] first the first atom
      # @param [Atom] second the second atom
      # @param [Hash] links the container of relations between atoms (is a
      #   sparse graph)
      # @return [Array] the array with positions in both directions or nil
      def positions_between(first, second, links)
        # TODO: there could be several positions between two atoms
        rule = inference_rules.find do |path, _|
          find_by_path(second, path, first, nil, links)
        end

        return unless rule

        position = rule.last
        opposite_position = first.lattice.opposite_relation(second.lattice, position)
        [position, opposite_position]
      end

      # Provides information on the maximum possible number of relations of crystal
      # lattice and bondary layer for each individual atom
      #
      # @return [Hash] the hash where keys are relation options and values are maximum
      #   numbers of correspond relations
      def relations_limit
        # this limit because engine framework provides just method #amorphNeighbour
        # which has assert to check that number of amorph atom neighbour is equal 1
        self.class.amorph_relations_limit.merge(crystal_relations_limit)
      end

    private

      # Recursively algorighm which finds target by path in links
      # @param [Atom] target the aim of find algorithm
      # @param [Array] path which is applied to links for find target
      # @param [Atom] current from which algorithm is begining
      # @param [Atom] prevent value of visited atom
      # @param [Hash] links in which path will be found or not
      # @return [Boolean] is target found or not
      def find_by_path(target, path, current, prevent, links)
        if path.empty?
          target == current
        else
          relation = path.first
          applicants = links[current].select do |atom, link|
            atom != prevent && link.it?(relation)
          end

          applicants.any? do |atom, _|
            find_by_path(target, path[1..-1], atom, current, links)
          end
        end
      end
    end

  end
end
