module VersatileDiamond
  module Concepts

    # Implementation which know about environment specs and has info about
    # positions between reactants and environment specs
    class There
      include Modules::GraphDupper
      include Modules::ListsComparer
      include SpecAtomSwapper
      include PositionsComparer
      extend Forwardable

      def_delegator :where, :description
      attr_reader :where # for graphs generators

      # Raises when target atom of sidepiece there object haven't lattice
      class ReversingError < Errors::Base
        attr_reader :spec
        def initialize(spec, atom)
          @spec, @atom = spec, atom
        end

        # Gets the keyname of invalid atom
        # @return [Symbol] the keyname of atom
        def keyname
          @spec.keyname(@atom)
        end
      end

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
        transform_where_links(:total_links)
      end

      # Gets possible cutten positions graph which uses just own links of where object
      # @return [Hash] the possible cutten graph of positions between target atoms of
      #   specs and environment atoms of specs
      def own_links
        transform_where_links(:links)
      end

      # Makes reversed there object
      # @param [Mcs::MappingResult] mapping by which the other side spec and atom will
      #   be gotten
      # @return [There] the reversed there object
      def reverse(mapping)
        reversed_refs = {}
        target_refs.each do |target, (spec, atom)|
          other_side_spec_atom = mapping.other_side(spec, atom)
          if other_side_spec_atom.last.lattice
            reversed_refs[target] = other_side_spec_atom
          else
            raise ReversingError.new(*other_side_spec_atom)
          end
        end

        self.class.new(where, reversed_refs)
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
        target_refs.values.map(&:first).uniq
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
        self == other ||
          (target_specs.size == other.target_specs.size &&
            env_specs.size == other.env_specs.size && same_positions?(other))
      end

      # Compares own positions between self and other there objects
      # @param [There] other there object which own positions will be checked
      # @return [Boolean] are same own positions or not
      def same_own_positions?(other)
        same_by_method?(:own_positions, other)
      end

      def to_s
        env_specs.map(&:name).join(' & ')
      end

      def inspect
        to_s
      end

    protected

      attr_reader :target_refs

      # Gets the list of own position tuples
      # @return [Array] the list of own position tuples
      def own_positions
        make_positions(own_links)
      end

    private

      # Gets the transformed links of where object where target symbols is replaced to
      # correspond spec-atom pairs of reactants
      #
      # @param [Symbol] links_method which will be called from where object
      # @return [Hash] the transformed links graph
      def transform_where_links(links_method)
        dup_graph(where.public_send(links_method)) do |v|
          v.is_a?(Symbol) ? target_refs[v] : v
        end
      end
    end

  end
end
