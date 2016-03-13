module VersatileDiamond
  module Organizers

    # @abstract
    class DependentSpec < DependentSimpleSpec

      # Checks that other spec has same atoms and links between them
      # @param [DependentBaseSpec] other the comparable spec
      # @return [Boolean] same or not
      def same?(other)
        other.is_a?(DependentSpec) ? spec.same?(other.spec) : other.same?(self)
      end

      # All species is not termination by default
      # @return [Boolean] false
      # @override
      def simple?
        false
      end

      # All species is not termination by default
      # @return [Boolean] false
      # @override
      def specific?
        false
      end
    end

  end
end
