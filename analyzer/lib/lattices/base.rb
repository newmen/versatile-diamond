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
          { Concepts::Bond::AMORPH_PARAMS => 1 }
        end
      end

      # @return [Integer]
      def hash
        self.class.hash
      end

      # @param [Base] other comparing lattice instance
      # @return [Boolean] is same lattice or not
      def ==(other)
        self.class == other.class
      end
      alias :eql? :==

      # @param [Base] other comparing lattice instance
      # @return [Integer] the comparation result
      def <=>(other)
        self.class.to_s <=> other.class.to_s
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
          same_lattice_opposite_relation(relation)
        elsif !relation.belongs_to_crystal?
          relation # there relation is a bond without face and direction
        else
          other_lattice(relation)
        end
      end

      # Finds position relation between passed atoms
      # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom] from
      #   which atom position will be found
      # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom] to
      #   which atom position will be found
      # @param [Hash] links the sparse graph that contain relations between atoms
      # @return [Concepts::Position] the detected position between atoms or nil
      def position_between(from, to, links)
        # TODO: there could be several positions between two atoms
        rule = inference_rules.find do |path, _|
          find_by_path(to, path, from, nil, links)
        end

        rule && rule.last
      end

      # Finds position relations between passed in crystal lattice limited by
      # relations container
      #
      # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom] from
      #   which atom position will be found
      # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom] to
      #   which atom position will be found
      # @param [Hash] links the sparse graph that contain relations between atoms
      # @return [Array] the array with positions in both directions or nil
      def positions_between(first, second, links)
        position = position_between(first, second, links)
        return unless position

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

      # Checks that relation belongs to flatten face of crystal
      # @param [Concepts::Bond] relation that will be checked
      # @return [Boolean] is belongs to flatten face or not
      def flatten?(relation)
        flatten_faces.include?(relation.face)
      end

      # @return [Hash]
      def surface_crystal_atom
        relations = bottom_relations.map { |r, n| [r] * n }.reduce(:+)
        actives_num = crystal_atom[:valence] - relations.size
        crystal_atom.merge({
          relations: relations,
          danglings: [ActiveBond.property] * actives_num
        })
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
          rels = links[current]
          return false unless rels

          relation_params = path.first
          applicants = rels.select do |atom, link|
            atom != current && atom != prevent && link.it?(relation_params)
          end

          applicants.any? do |atom, _|
            find_by_path(target, path[1..-1], atom, current, links)
          end
        end
      end
    end

  end
end
