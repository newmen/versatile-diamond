module VersatileDiamond
  module Concepts

    # General atom for base specs. Contain valence and lattice if it setted.
    class Atom < Named

      # Exception class for incorrect valence case
      class IncorrectValence < Exception
        attr_reader :atom
        def initialize(atom); @atom = atom end
      end

      class << self
        # Checks passed atom to hydrogen
        # @param [Atom] atom is checking atom
        # @return [Boolean] is it?
        def is_hydrogen?(atom)
          atom.name == :H
        end
      end

      attr_reader :valence
      attr_accessor :lattice

      # @param [String] name is atom name
      # @param [Integer] valence of atom (must be more than 0)
      def initialize(name, valence)
        super(name)
        @valence = valence
      end

      # Compares two atoms and if atom is instance of same class then comparing
      # the name and the lattice. Another cases action is deligate to
      # comparable atom.
      #
      # @param [Atom | AtomReference | SpecificAtom] other the other atom with
      #   which comparing do
      # @return [Boolean] is the same atom or not
      def same?(other)
        if self.class == other.class
          name == other.name && lattice == other.lattice
        else
          other.same?(self)
        end
      end

      # Not specified atom cannot have active bonds
      # (property is used in Hanser's algorithm)
      #
      # @return [Integer] 0 active bonds
      def actives
        0
      end

      # Compares with other atom
      # @param [Atom | AtomReference | SpecificAtom] other the atom with which
      #   compare
      # @return [Array] the array of relevants state symbols
      def diff(other)
        other.is_a?(SpecificAtom) ? other.relevants : []
      end

      # Finds all relation instances for current atom in passed spec
      # @param [Spec] spec the spec in which relations will be found, must
      #   contain current atom
      # @return [Array] the array of relations
      def relations_in(spec)
        spec.links[self].dup
      end

      def to_s
        @lattice ? "#{name}%#{@lattice}" : name.to_s
      end
    end

  end
end
