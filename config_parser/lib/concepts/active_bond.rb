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

      def to_s
        name
      end

      # def cover?(specific_spec)
      #   specific_spec.active?
      # end
    end

  end
end
