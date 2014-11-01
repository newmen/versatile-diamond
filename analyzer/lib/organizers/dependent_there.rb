module VersatileDiamond
  module Organizers

    # Contain some there and provides behavior for dependent entities set
    class DependentThere
      extend Forwardable

      def_delegators :@there, :where, :swap_source, :used_atoms_of
      # attr_reader :there

      # Stores wrappable there
      # @param [Concepts::There] there the wrappable there
      def initialize(there)
        @there = there
      end

      # Iterates each enviromnet specie
      # @yield [Concepts::SurfaceSpec | Concepts::SpecificSpec] do with each
      #   enviromnent specie
      # @return [Enumerator] if block doesn't given
      def each_source(&block)
        @there.env_specs.each(&block)
      end
    end

  end
end
