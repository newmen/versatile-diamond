module VersatileDiamond
  module Concepts

    # Implementation which know about environment specs and has info about
    # positions between reactants and environment specs
    class There
      extend Forwardable
      include SpecAtomSwapper

      def_delegators :where, :description, :used_keynames_of, :visit
      attr_reader :where, :positions

      # Initialize a new instance of there object
      # @param [Where] where the basic where object
      # @param [Hash] positions the hash where keys is atoms of reactants and
      #   values is hashes of environment specs atoms to position objects
      def initialize(where, positions)
        # TODO: may be we're not need in where object there
        @where, @positions = where, positions
      end

      # Makes a duplicate of there object
      # @param [There] other the there object which will be duplicated
      def initialize_copy(other)
        duplicated_positions = other.positions.map do |spec_atom1, links|
          duplicated_links = links.map do |spec_atom2, position|
            [spec_atom2.dup, position]
          end
          [spec_atom1.dup, duplicated_links]
        end

        @where = other.where
        @positions = Hash[duplicated_positions]
      end

      # Provides environment species
      # @return [Array] all species stored in used where and in their parents
      def env_specs
        where.all_specs
      end

      # Swaps environment source spec from some to some
      # @param [SpecificSpec] from the spec from which need to swap
      # @param [SpecificSpec] to the spec to which need to swap
      def swap_source(from, to)
        where.swap_source(from, to)
        positions.each do |_, links|
          links.each { |spec_atom, _| swap(spec_atom, from, to) }
        end
      end

      # Provides target species
      # @return [Array] the array of target species
      def target_specs
        positions.map(&:first).map(&:first)
      end

      # Swaps target spec from some to some
      # @param [SpecificSpec] from the spec from which need to swap
      # @param [SpecificSpec] to the spec to which need to swap
      def swap_target(from, to)
        positions.each { |spec_atom, _| swap(spec_atom, from, to) }
      end

      # Compares two there objects
      # @param [There] other with which comparison
      # @return [Boolean] are their wheres equal
      def same?(other)
        where == other.where
      end

      # Verifies that passed there object is covered by the current
      # @param [There] other the verifying there object
      # @return [Boolean] is cover or not
      def cover?(other)
        other.where.parents.include?(where)
      end

      def to_s
        env_specs.map(&:name).join(' & ')
      end

      def inspect
        to_s
      end
    end

  end
end
