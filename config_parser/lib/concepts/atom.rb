module VersatileDiamond

  module Concepts

    # General atom for base specs. Contain valence and lattice if it setted.
    class Atom < Concepts::Base
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


      # def same?(other)
      #   if self.class == other.class
      #     @name == other.name && @lattice == other.lattice
      #   else
      #     other.same?(self)
      #   end
      # end

      # def diff(other)
      #   other.is_a?(SpecificAtom) ? other.diff(self) : []
      # end

      def to_s
        @lattice ? "#{@name}%#{@lattice}" : @name
      end
    end

  end

end
