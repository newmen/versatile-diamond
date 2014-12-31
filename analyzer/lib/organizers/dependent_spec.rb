module VersatileDiamond
  module Organizers

    # Contain some spec and set of dependent reactions, theres and children
    # @abstract
    class DependentSpec < DependentSimpleSpec
      extend Collector

      collector_methods :there

      # @override
      def initialize(*)
        super
        @theres = nil
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
