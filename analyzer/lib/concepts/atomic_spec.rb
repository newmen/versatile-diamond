module VersatileDiamond
  module Concepts

    # Represents a spec which contain just one unovalence atom
    class AtomicSpec < TerminationSpec
      include NoBond
      extend Forwardable

      def_delegators :@atom, :name, :to_s

      # Store unovalence atom instance
      # @param [Atom] atom the atom which behaves like spec
      def initialize(atom)
        @atom = atom
      end

      # Compares other instance with current
      # @param [TerminationSpec | SpecificSpec] other object with which comparation
      #   will be complete
      # @return [Boolean] is other a instance of same class or not
      def == (other)
        self.class == other.class && name == other.name
      end

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

      # Calls correspond method in atom properties
      # @param [AtomProperties] prop the observed atom properties
      def terminations_num(prop)
        if hydrogen?
          prop.total_hydrogens_num
        else
          prop.count_danglings(name)
        end
      end

      # Verifies that passed specific spec is covered by the current
      # @param [SpecificSpec] specific_spec the verifying spec
      # @param [Atom | SpecificAtom] atom the verifying atom
      # @return [Boolean] is cover or not
      def cover?(specific_spec, atom)
        !specific_spec.gas? && specific_spec.has_termination?(atom, self)
      end
    end

  end
end
