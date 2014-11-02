module VersatileDiamond
  module Organizers

    # Contain some there and provides behavior for dependent entities set
    class DependentThere
      extend Forwardable

      def_delegators :@there, :where, :swap_source
      # attr_reader :there

      # Stores wrappable there
      # @param [Concepts::There] there the wrappable there
      def initialize(there)
        @there = there
      end

      # Gets atoms of passed spec
      # @param [DependentWrappedSpec] spec is the using internal sidepiece
      # @return [Array] the array of using atoms
      def used_atoms_of(dept_spec)
        @there.used_atoms_of(dept_spec.spec)
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
