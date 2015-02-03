module VersatileDiamond
  module Organizers

    # Contain some there and provides behavior for dependent entities set
    class DependentThere
      extend Forwardable

      def_delegators :there, :where, :swap_source, :use_similar_source?
      attr_reader :lateral_reaction

      # Stores wrappable there
      # @param [DependentLateralReaction] lateral_reaction which uses also passed there
      #   object
      # @param [Concepts::There] there the wrappable there
      def initialize(lateral_reaction, there)
        @lateral_reaction = lateral_reaction
        @there = there
      end

      # Gets atoms of passed spec
      # @param [DependentWrappedSpec] spec is the using internal sidepiece
      # @return [Array] the array of using atoms
      def used_atoms_of(dept_spec)
        there.used_atoms_of(dept_spec.spec)
      end

      # Iterates each enviromnet specie
      # @yield [Concepts::SurfaceSpec | Concepts::SpecificSpec] do with each
      #   enviromnent specie
      # @return [Enumerator] if block doesn't given
      def each_source(&block)
        there.env_specs.each(&block)
      end

      # Compares raw positions between self and other there objects
      # @param [DependentThere] other there object which raw positions will be checked
      # @return [Boolean] are same raw positions or not
      def same_positions?(other)
        there.same_positions?(other.there)
      end

    protected

      attr_reader :there

    end

  end
end
