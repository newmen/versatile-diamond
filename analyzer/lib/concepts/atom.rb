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
        # Gets a hydrogen atom instance
        # @return [Atom] the hydrogen atom
        def hydrogen
          @_hydrogen ||= Atom.new('H', 1)
        end

        # Checks passed atom to hydrogen
        # @param [Atom] atom is checking atom
        # @return [Boolean] is it?
        def hydrogen?(atom)
          atom.same?(hydrogen)
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

      # @return [Atom] self instance without specific states
      def clean
        self
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
      # the name and the lattice. Another cases action is delegate to
      # comparable atom.
      #
      # @param [Atom | AtomReference | SpecificAtom] other comparing atom
      # @return [Boolean] is the same atom or not
      def same?(other)
        compare_by(other, &:same?)
      end

      # Compares two atoms without comparing them specific states
      # @param [Atom | AtomReference | SpecificAtom] other comparing atom
      # @return [Boolean] same or not
      def original_same?(other)
        compare_by(other, &:original_same?)
      end

      # @param [Atom | AtomReference | SpecificAtom] other comparing atom
      # @return [Boolean] are accurate same atoms or not
      def accurate_same?(other)
        (self.class == other.class && equal_properties?(other)) ||
          (other.is_a?(VeiledAtom) && accurate_same?(other.original))
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

      # Gets the relations limits of current atom. Used for build bulk structures or to
      # make the find specie algorithm.
      #
      # @return [Hash] the hash of limits of relations
      def relations_limits
        if lattice
          lattice.instance.relations_limit
        else
          { Bond::AMORPH_PARAMS => valence }
        end
      end

      def to_s
        "#{name}#{@lattice}"
      end

      def inspect
        to_s
      end

    private

      # Compares two instances by some method if other instance is object of
      # another class
      #
      # @param [Atom | AtomReference | SpecificAtom] other the comparable atom
      # @yield [Atom | AtomReference | SpecificAtom] comparation method
      # @return [Boolean] comparation result
      def compare_by(other, &block)
        self.class == other.class ? equal_properties?(other) : block[other, self]
      end

      # @return [Boolean] are equal properties of self and other atoms or not
      def equal_properties?(other)
        name == other.name && valence == other.valence && lattice == other.lattice
      end
    end

  end
end
