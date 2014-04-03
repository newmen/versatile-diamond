module VersatileDiamond
  module Concepts

    # Represents a spec which contain just one unovalence atom
    class AtomicSpec < TerminationSpec
      extend Forwardable

      # Store unovalence atom instance
      # @param [Atom] atom the atom which behaves like spec
      def initialize(atom)
        @atom = atom
      end

      def_delegator :@atom, :name

      # Is hydrogen or not?
      # @return [Boolean]
      def hydrogen?
        Atom.hydrogen?(@atom)
      end

      # Each atomic spec have 1 external bonds
      # @return [Integer] one
      def external_bonds
        1
      end

      # Compares with an other spec
      # @param [TerminationSpec | SpecificSpec] other with which comparison
      # @return [Boolean] is specs same or not
      def same?(other)
        self.class == other.class && name == other.name
      end

      # Verifies that passed specific spec is covered by the current
      # @param [SpecificSpec] specific_spec the verifying spec
      # @param [Atom | SpecificAtom] atom the verifying atom
      # @return [Boolean] is cover or not
      def cover?(specific_spec, atom)
        !specific_spec.gas? && specific_spec.has_termination?(atom, @atom)
      end

      def to_s
        "[#{@atom}]"
      end
    end

  end
end
