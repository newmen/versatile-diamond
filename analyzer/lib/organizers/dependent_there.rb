module VersatileDiamond
  using Patches::RichArray

  module Organizers

    # Contain some there and provides behavior for dependent entities set
    class DependentThere
      extend Forwardable

      def_delegators :there, :swap_source, :use_similar_source?
      def_delegator :there, :where # for graphs generators
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

      # Gets the set of target spec-atoms
      # @return [Set] the set of target spec-atoms
      def targets
        there.links.keys.to_set
      end

      # Verifies that passed there object is covered by the current
      # @param [There] other the verifying there object
      # @return [Boolean] is cover or not
      def cover?(other)
        positions_dup = positions.dup
        other.positions.all? do |opos|
          positions_dup.delete_one do |spos|
            Concepts::PositionsComparer.same_pos_tuples?(spos, opos)
          end
        end
      end

      # Compares two dependent there objects
      # @param [DependentThere] other there object which will be compared
      # @return [Boolean] are same objects or not
      def same?(other)
        there.same?(other.there)
      end

      # Compares own positions between self and other there objects
      # @param [DependentThere] other there object which own positions will be checked
      # @return [Boolean] are same own positions or not
      def same_own_positions?(other)
        there.same_own_positions?(other.there)
      end

    protected

      def_delegator :there, :positions
      attr_reader :there

    end

  end
end
