module VersatileDiamond
  module Organizers

    # Contain some spec and set of dependent reactions, theres and children
    class DependentSimpleSpec
      extend Forwardable
      extend Collector

      def_delegators :spec, :name, :gas?
      collector_methods :reaction
      attr_reader :spec

      # Stores wrappable spec
      # @param [Concepts::AtomicSpec | Concepts::ActiveBond |
      #         Concepts::Spec | Concepts::SpecificSpec] spec the wrappable spec
      def initialize(spec)
        @spec = spec
        @reactions = nil
      end

      # Checks that other spec is same
      # @param [DepdendentSimpleSpec] other the comparable spec
      # @return [Boolean] same or not
      def same?(other)
        self.class == other.class && spec.same?(other.spec)
      end

      # Simple spec without anchors
      # @return [Array] the empty array
      def anchors
        []
      end

      # Simple spec does not have links
      # @return [Hash] the empty hash
      def links
        {}
      end

      # Gets number of external bonds for simple spec
      # @return [Integer] 0
      def external_bonds
        0
      end

      # All species is not termination by default
      # @return [Boolean] false
      def termination?
        false
      end

      # All species is not termination by default
      # @return [Boolean] false
      def simple?
        true
      end

      # All species is not termination by default
      # @return [Boolean] false
      def specific?
        true
      end

      # Simple species are not excess
      # @return [Boolean] false
      def excess?
        false
      end

      # Simple species are not unused
      # @return [Boolean] false
      def unused?
        true
      end

      def inspect
        "(#{spec.inspect})"
      end
    end

  end
end
