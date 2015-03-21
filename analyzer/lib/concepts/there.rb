module VersatileDiamond
  module Concepts

    # Implementation which know about environment specs and has info about
    # positions between reactants and environment specs
    class There
      include Modules::GraphDupper
      include SpecAtomSwapper
      extend Forwardable

      def_delegator :where, :description
      attr_reader :where, :target_refs

      # Initialize a new instance of there object
      # @param [Where] where the basic where object
      # @param [Hash] target_refs the hash of references from target name to
      #   real reactant and it atom
      def initialize(where, target_refs)
        @where, @target_refs = where, target_refs
      end

      # Makes a duplicate of there object
      # @param [There] other the there object which will be duplicated
      def initialize_copy(other)
        @where = other.where
        @target_refs = Hash[other.target_refs.map { |nm, sa| [nm, sa.dup] }]
      end

      # Gets the positions graph
      # @return [Hash] the graph of positions between target atoms of specs and
      #   environment atoms of specs
      def links
        dup_graph(where.total_links) do |v|
          v.is_a?(Symbol) ? target_refs[v] : v
        end
      end

      # Provides environment species
      # @return [Array] all species stored in used where and in their parents
      def env_specs
        where.all_specs.uniq
      end

      # Checks that passed spec is used in current there object
      # @param [SpecificSpec] spec which will be checked
      # @return [Boolan] is used similar spec or not
      def use_similar_source?(spec)
        target_refs.any? { |_, (s, _)| s == spec } ||
          where.total_links.any? do |_, rels|
            rels.any? { |(s, _), _| s == spec }
          end
      end

      # Swaps environment source spec from some to some
      # @param [SpecificSpec] from the spec from which need to swap
      # @param [SpecificSpec] to the spec to which need to swap
      def swap_source(from, to)
        where.swap_source(from, to)
        swap_target(from, to)
      end

      # Provides target species
      # @return [Array] the array of target species
      def target_specs
        target_refs.values.map(&:first)
      end

      # Swaps target spec from some to some
      # @param [SpecificSpec] from the spec from which need to swap
      # @param [SpecificSpec] to the spec to which need to swap
      def swap_target(from, to)
        @target_refs = Hash[@target_refs.map { |nm, sa| [nm, swap(sa, from, to)] }]
      end

      # Swaps atoms which uses as target
      # @param [SpecificSpec] spec the specific spec the atom of which will be swapped
      # @param [Atom] from the used atom
      # @param [Atom] to the new atom
      def swap_target_atom(spec, from, to)
        new_refs = @target_refs.map { |nm, sa| [nm, swap_only_atoms(sa, from, to)] }
        @target_refs = Hash[new_refs]
      end

      # Swaps atoms in environment
      # @param [SpecificSpec] spec the specific spec the atom of which will be swapped
      # @param [Atom] from the used atom
      # @param [Atom] to the new atom
      def swap_env_atom(spec, from, to)
        where.swap_atom(spec, from, to)
      end

      # Gets atoms of passed spec which used in positions
      # @param [Spec | SpecificSpec] spec by which the atoms will be collected
      # @return [Array] the array of using atoms
      def used_atoms_of(spec)
        atoms = target_refs.each_with_object([]) do |(_, (s, a)), acc|
          acc << a if s == spec
        end

        (atoms + where.used_atoms_of(spec)).uniq
      end

      # Compares two there objects
      # @param [There] other with which comparison
      # @return [Boolean] are their wheres equal
      def same?(other)
        # TODO: not complete check!
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
