module VersatileDiamond
  module Concepts

    # Represents a some "termination" spec which can be involved to ubiquitous
    # reaction
    class TerminationSpec

      # Each termination spec have 0 external_bonds
      # @return [Integer] zero
      def external_bonds
        0
      end

      # Termination spec cannot belong to the gas phase
      # @return [Boolean] false
      def is_gas?
        false
      end

      # Termination spec cannot be extended
      # @return [Boolean] false
      def extendable?
        false
      end

      # def visit(visitor)
      #   visitor.accept_termination_spec(self)
      # end

      # def same?(other)
      #   self.class == other.class && to_s == other.to_s
      # end
    end

  end
end
