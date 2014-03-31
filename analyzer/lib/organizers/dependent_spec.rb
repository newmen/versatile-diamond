module VersatileDiamond
  module Organizers

    # Contain some spec and set of dependent theres and reactions
    # @abstract
    class DependentSpec
      extend Collector

      collector_methods :there, :reaction, :child
      attr_reader :spec

      # Stores wrappable spec
      # @param [Concepts::Spec | Concepts::SpecificSpec] spec the wrappable
      #   spec
      def initialize(spec)
        @spec = spec
      end

    end

  end
end
