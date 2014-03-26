module VersatileDiamond
  module Concepts

    # Represents a spec which contain just one active bond
    class ActiveBond < TerminationSpec

      # The name of active bond
      # @return [Symbol] the star which represents active bond
      def name
        :*
      end

      # Each active bond have 0 external bonds
      # @return [Integer] zero
      def external_bonds
        0
      end

      # Compares with an other spec
      # @param [TerminationSpec | SpecificSpec] other with which comparison
      # @return [Boolean] is specs same or not
      def same?(other)
        self.class == other.class
      end

      # Verifies that passed specific spec is covered by the current
      # @param [SpecificSpec] specific_spec the verifying spec
      # @param [Atom | SpecificAtom] atom the verifying atom
      # @return [Boolean] is cover or not
      def cover?(specific_spec, atom)
        !specific_spec.gas? && atom.is_a?(SpecificAtom) && atom.actives > 0
      end

      def to_s
        name
      end
    end

  end
end
