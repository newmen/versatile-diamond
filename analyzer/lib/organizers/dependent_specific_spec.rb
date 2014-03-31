module VersatileDiamond
  module Organizers

    # Contain some specific spec and set of dependent specs
    class DependentSpecificSpec < DependentSpec
      extend Forwardable

      def_delegators :@spec, :reduced, :could_be_reduced?, :specific?

      def name
        spec.respond_to?(:full_name) ? spec.full_name : spec.name
      end

      def base_spec
        spec.spec
      end

    end

  end
end
