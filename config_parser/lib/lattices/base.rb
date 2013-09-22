module VersatileDiamond
  module Lattices

    # The base class for lattice instanes
    # @abstract
    class Base

      # Exception class for case when used bond is incorrect
      class UndefinedRelation < Exception
        attr_reader :relation
        def initialize(relation); @relation = relation end
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
        elsif relation.face.nil?
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
        rule = inference_rules.find do |path, position|
          current, prevent = first, nil
          completion = path.all? do |relation|
            applicants = links[current].select do |atom, link|
              atom != prevent && link.it?(relation)
            end
            next nil if applicants.size != 1 # ambiguity in the choice

            prevent = current
            current = applicants.first.first
          end

          completion && current == second
        end

        return unless rule

        position = rule.last
        opposite_position =
          first.lattice.opposite_relation(second.lattice, position)
        [position, opposite_position]
      end

    private

      # Basics relation options
      [100, 110].each do |face|
        [:front, :cross].each do |dir|
          define_method("#{dir}_#{face}") do
            { face: face, dir: dir }
          end
        end
      end

      # Basics position instances
      [
        [100, :front],
        [100, :cross],
      ].each do |face, dir|
        define_method("position_#{dir}_#{face}") do
          Position[face: face, dir: dir]
        end
      end

    end

  end
end
