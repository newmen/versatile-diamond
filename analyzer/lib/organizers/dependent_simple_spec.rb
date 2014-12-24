module VersatileDiamond
  module Organizers

    # Contain some spec and set of dependent reactions, theres and children
    class DependentSimpleSpec
      extend Forwardable
      extend Collector

      def_delegators :@spec, :name, :gas?
      collector_methods :reaction
      attr_reader :spec

      # Stores wrappable spec
      # @param [Concepts::AtomicSpec | Concepts::ActiveBond |
      #         Concepts::Spec | Concepts::SpecificSpec] spec the wrappable spec
      def initialize(spec)
        @spec = spec
      end

      # Simple spec does not have links
      # @return [Hash] the empty hash
      def links
        {}
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
    end

  end
end
