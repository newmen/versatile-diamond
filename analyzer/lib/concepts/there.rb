module VersatileDiamond
  module Concepts

    # Implementation which know about environment specs and has info about
    # positions between reactants and environment specs
    class There
      extend Forwardable
      include SpecAtomSwapper

      def_delegator :where, :description
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
        all_specs = positions.each_with_object([]) do |(_, links), acc|
          links.each { |(spec, _), _| acc << spec }
        end
        all_specs.uniq
      end

      # Checks that passed spec is used in current there object
      # @param [SpecificSpec] spec which will be checked
      # @return [SpecificSpec] the found result or nil
      def similar_source(spec)
        result = nil
        check_lambda = -> s { result = s if s == spec }
        positions.each do |(s, _), rels|
          break if check_lambda[s] || rels.find { |(o, _), _| check_lambda[o] }
        end
        result
      end

      # Swaps environment source spec from some to some
      # @param [SpecificSpec] from the spec from which need to swap
      # @param [SpecificSpec] to the spec to which need to swap
      def swap_source(from, to)
        where.swap_source(from, to)
        @positions = @positions.each_with_object({}) do |(sa, links), acc|
          acc[swap(sa, from, to)] = links.map do |spec_atom, rel|
            [swap(spec_atom, from, to), rel]
          end
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
        @positions = @positions.each_with_object({}) do |(spec_atom, links), acc|
          acc[swap(spec_atom, from, to)] = links
        end
      end

      # Swaps atoms which uses as target
      # @param [SpecificSpec] spec the specific spec the atom of which will be swapped
      # @param [Atom] from the used atom
      # @param [Atom] to the new atom
      def swap_target_atom(spec, from, to)
        @positions = @positions.each_with_object({}) do |(spec_atom, links), acc|
          acc[swap_only_atoms(spec_atom, spec, from, to)] = links
        end
      end

      # Swaps atoms in environment
      # @param [SpecificSpec] spec the specific spec the atom of which will be swapped
      # @param [Atom] from the used atom
      # @param [Atom] to the new atom
      def swap_env_atom(spec, from, to)
        return if from == to
        @positions = @positions.each_with_object({}) do |(spec_atom, links), acc|
          acc[spec_atom] = links.map do |sa, rel|
            [swap(sa, from, to), rel]
          end
        end
      end

      # Gets atoms of passed spec which used in positions
      # @param [Spec | SpecificSpec] spec by which the atoms will be collected
      # @return [Array] the array of using atoms
      def used_atoms_of(spec)
        all_atoms = positions.each_with_object([]) do |((sk, ak), rels), acc|
          acc << ak if sk == spec
          rels.each { |(sv, av), _| acc << av if sv == spec }
        end

        all_atoms.uniq
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
