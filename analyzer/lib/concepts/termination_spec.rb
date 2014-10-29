module VersatileDiamond
  module Concepts

    # Represents a some "termination" spec which can be involved to ubiquitous
    # reaction
    class TerminationSpec
      include Visitors::Visitable

      # Termination spec cannot belong to the gas phase
      # @return [Boolean] false
      def gas?
        false
      end

      # Termination spec isn't simple
      # @return [Boolean] false
      def simple?
        false
      end

      # Termination spec cannot be extended
      # @return [Boolean] false
      def extendable?
        false
      end

      # Compares with an other spec
      # @param [TerminationSpec | SpecificSpec] other with which comparison
      # @return [Boolean] is specs same or not
      def same?(other)
        self == other
      end
    end

  end
end
