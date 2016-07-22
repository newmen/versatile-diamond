module VersatileDiamond
  module Organizers

    # @abstract
    class DependentSpec < DependentSimpleSpec

      def_delegator :spec, :keyname

      # Checks that other spec has same atoms and links between them
      # @param [DependentSpec] other the comparable spec
      # @return [Boolean] same or not
      # @override
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
