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

      # Termination spec has size equal 1
      # @return [Integer] 1
      def size
        1
      end
    end

  end
end
