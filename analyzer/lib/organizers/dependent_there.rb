module VersatileDiamond
  module Organizers

    # Contain some there and provides behavior for dependent entities set
    class DependentThere
      include Modules::SpecLinksAdsorber
      include Modules::SpecAtomSwapper
      extend Forwardable

      def_delegators :there, :description, :use_similar?, :inspect
      def_delegator :there, :where # for graphs generators

      attr_reader :lateral_reaction

      # Stores wrappable there
      # @param [DependentLateralReaction] lateral_reaction in which current there
      #   object uses
      # @param [Concepts::There] there the wrappable there
      def initialize(lateral_reaction, there)
        @lateral_reaction, @there = lateral_reaction, there

        @_links = nil
      end

      # Checks that if result spec is veiled then fill ChunkLinksMerger and update
      # own links
      #
      # @param [Symbol] target the type of swapping species
      # @param [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec] from
      #   the spec from which need to swap
      # @param [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec] to
      #   the spec to which need to swap
      def swap_on(target, from, to)
        if target == :source
          @_links = nil
          there.swap_source(from, to)
        end
      end

      # Gets the extendes links of there object with links of sidepiece species
      # @return [Hash] the extended links of there object with links of sidepiece specs
      def links
        return @_links if @_links
        @_links = adsorb_links(there.links, there.env_specs)
        there.links.each do |target, rels| # reverse rels from sidepiece to targets
          target_ltc = target.last.lattice
          rels.each do |sa, r|
            @_links[sa] ||= []
            @_links[sa] << [target, sa.last.lattice.opposite_relation(target_ltc, r)]
          end
        end
        @_links
      end

      # Gets atoms of passed spec
      # @param [DependentWrappedSpec] spec is the using internal sidepiece
      # @return [Array] the array of using atoms
      def used_atoms_of(dept_spec)
        there.used_atoms_of(dept_spec.spec)
      end

      # Iterates each enviromnet specie
      # @param [Symbol] target the type of iterating species
      # @yield [Concepts::SurfaceSpec | Concepts::SpecificSpec] do with each
      #   enviromnent specie
      # @return [Enumerator] if block doesn't given
      def each(target, &block)
        (target == :source ? there.env_specs : []).each(&block)
      end

      # Gets the set of target spec-atoms
      # @return [Set] the set of target spec-atoms
      def targets
        there.links.keys.to_set
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

    private

      attr_reader :there

    end

  end
end
