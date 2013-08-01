module VersatileDiamond
  module Concepts

    # Represents a spec which contain just one active bond
    class ActiveBond < TerminationSpec

      # The name of active bond
      # @return [Symbol] the star which represents active bond
      def name
        :*
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
