module VersatileDiamond
  module Concepts

    # General atom for base specs. Contain valence and lattice if it setted.
    class Atom < Named

      # Exception class for incorrect valence case
      class IncorrectValence < Errors::Base
        attr_reader :atom
        def initialize(atom); @atom = atom end
      end

      class << self
        # Checks passed atom to hydrogen
        # @param [Atom] atom is checking atom
        # @return [Boolean] is it?
        def hydrogen?(atom)
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

      # Simple atom is not reference
      # @return [Boolean] false
      def reference?
        false
      end

      # Simple atom couldn't be specified
      # @return [Boolean] false
      def specific?
        false
      end

      # Compares two atoms and if atom is instance of same class then comparing
      # the name and the lattice. Another cases action is deligate to
      # comparable atom.
      #
      # @param [Atom | AtomReference | SpecificAtom] other the other atom with
      #   which comparing do
      # @return [Boolean] is the same atom or not
      def same?(other)
        compare_by_method(:same?, other)
      end

      # Compares two atoms without comparing them specific states
      # @param [Atom | AtomReference | SpecificAtom] other the comparable atom
      # @return [Boolean] same or not
      def original_same?(other)
        compare_by_method(:original_same?, other)
      end

      # Not specified atom cannot have active bonds
      # @return [Integer] 0 active bonds
      def actives
        0
      end

      # Not specified atom cannot have monovalent atoms
      # @return [Array] the empty array
      def monovalents
        []
      end

      %w(incoherent unfixed).each do |state|
        # Base atom cannot be #{state}
        # @return [Boolean] false
        define_method(:"#{state}?") { false }
      end

      # Compares with other atom
      # @param [Atom | AtomReference | SpecificAtom] other the atom with which
      #   compare
      # @return [Array] the array of relevants state symbols
      def diff(other)
        other.relevants
      end

      # Simple atom couldn't contain relevant states
      # @return [Array] the empty array
      def relevants
        []
      end

      # Simple atom couldn't contain additional relations
      # @return [Array] the empty array
      def additional_relations
        []
      end

      # Gets original valence of atom
      # @return [Integer] the original valence of atom
      def original_valence
        @valence
      end

      def to_s
        "#{name}#{@lattice}"
      end

      def inspect
        to_s
      end

    private

      # Finds all relation instances for current atom in passed spec.
      # Hidden from around, this method could be called only from atom relation.
      #
      # @param [Spec] spec the spec in which relations will be found, must
      #   contain current atom
      # @return [Array] the array of relations
      def relations_in(spec)
        spec.links[self].map { |a, l| [a.dup, l] }
      end

      # Compares two instances by some method if other instance is object of
      # another class
      #
      # @param [Symbol] method by which will instances will be compared if classes is
      #   different
      # @param [Atom | AtomReference | SpecificAtom] other the comparable atom
      # @return [Boolean] comparation result
      def compare_by_method(method, other)
        if self.class == other.class
          name == other.name && lattice == other.lattice
        else
          other.public_send(method, self)
        end
      end
    end

  end
end
