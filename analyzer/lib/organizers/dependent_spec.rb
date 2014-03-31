module VersatileDiamond
  module Organizers

    # Contain some spec and set of dependent reactions, theres and children
    # @abstract
    class DependentSpec
      extend Collector

      collector_methods :reaction, :there, :child
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
