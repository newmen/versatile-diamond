module VersatileDiamond
  module Organizers

    # Contain some there and set of dependent !!!!!!
    class DependentThere
      extend Forwardable

      def_delegators :@there, :env_specs, :swap_source, :used_keynames_of
      # attr_reader :there

      # Stores wrappable there
      # @param [Concepts::There] there the wrappable there
      def initialize(there)
        @there = there
      end
    end

  end
end
