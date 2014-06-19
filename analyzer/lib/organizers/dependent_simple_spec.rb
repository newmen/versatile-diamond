module VersatileDiamond
  module Organizers

    # Contain some spec and set of dependent reactions, theres and children
    class DependentSimpleSpec
      extend Forwardable
      extend Collector

      def_delegators :@spec, :name
      collector_methods :reaction
      attr_reader :spec

      # Stores wrappable spec
      # @param [Concepts::AtomicSpec | Concepts::ActiveBond |
      #         Concepts::Spec | Concepts::SpecificSpec] spec the wrappable spec
      def initialize(spec)
        @spec = spec
      end

    end

  end
end
