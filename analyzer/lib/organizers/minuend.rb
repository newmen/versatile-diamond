module VersatileDiamond
  module Organizers

    # Provides method for minuend behavior
    module Minuend
      include Module::ListsComparer

      # Checks that current minuend instance is empty or not
      # @return [Boolean] empty or not
      def empty?
        links.empty?
      end

      # The number of links between atoms
      # @return [Integer] the number of links
      def atoms_num
        links.size
      end

      ['', 'clean_'].each do |prefix|
        # Counts the atom reference instances
        # @return [Integer] the number of atom references
        define_method(:"#{prefix}relations_num") do
          send("#{prefix}links").values.map(&:size).reduce(:+)
        end
      end

      # Provides relations of atom in current resudual
      # @param [Concepts::Atom | Concepts::AtomRelation] atom for which relations will
      #   be got
      # @option [Boolean] :with_atoms if true, then relations will contain neighbour
      #   atoms too
      # @return [Array] the array of atom relations
      def relations_of(atom, with_atoms: false)
        relations = links[atom]
        with_atoms ? relations : relations.map(&:last)
      end

      # Removes excess positions from current links graph
      # @return [Hash] the links of concept specie without excess positions
      def clean_links
        @clean_links ||= cleanable_links.each.with_object({}) do |(atom, rels), result|
          result[atom] = rels.reject { |a, r| excess_position?(r, atom, a) }
        end
      end

      # Makes residual of difference between top and possible parent
      # @param [DependentBaseSpec | DependentSpecificSpec] other the subtrahend spec
      # @return [SpecResidual] the residual of diference between arguments or nil if
      #   it doesn't exist
      def - (other, prev_refs = {})
        mirror = mirror_to(other)
        return nil if other.links.size != mirror.size

        residuals = {}
        collected_refs = {}
        pairs_from(mirror).each do |own_atom, other_atom|
          unless other_atom
            residuals[own_atom] = links[own_atom] # <-- same as bottom
            next
          end

          is_diff = different_used_relations?(other, own_atom, other_atom) ||
            used?(mirror.keys, own_atom)

          if is_diff
            residuals[own_atom] = links[own_atom] # <-- same as top
            collected_refs[own_atom] = other_atom
          end
        end

        SpecResidual.new(residuals, merge(prev_refs, collected_refs))
      end

      # Finds first intersec with some spec
      # @param [DependentBaseSpec] spec the checkable specie
      # @return [Array] the array of each pair of intersection or nil if intersection
      #   have not fond
      def mirror_to(spec)
        args = [self, spec, { collaps_multi_bond: true }]
        first = Mcs::SpeciesComparator.first_general_intersec(*args)
        first && Hash[first.to_a]
      end

    protected

      # Checks that atom have amorph bond and if it is true then relations returns else
      # only bonds will returned
      #
      # @param [Atom] atom see at #relations_of same argument
      # @return [Array] the array of relations without position relations
      def used_relations_of(atom)
        pairs = relations_of(atom, with_atoms: true).reject do |a, r|
          excess_position?(r, atom, a)
        end
        pairs.map(&:last)
      end

    private

      # Makes pairs of atoms from mirror. If some atoms from current links are not
      # presented in mirror then them will be added to head of pairs.
      #
      # @param [Hash] mirror of atoms from current spec to subtrahend spec
      # @return [Array] the array of atoms pairs
      def pairs_from(mirror)
        pairs = mirror.to_a
        if pairs.size < links.size
          (links.keys - mirror.keys).each do |residual_atom|
            pairs.unshift([residual_atom, nil])
          end
        end
        pairs
      end

      # Checks that relations gotten by method of both atom have same relations sets
      # @param [Symbol] method name which will called
      # @param [DependentBaseSpec | DependentSpecificSpec] other same as #- argument
      # @param [Concepts::SpecificAtom | Concepts::Atom | Concepts::AtomReference]
      #   own_atom the major of comparable atoms
      # @param [Concepts::Atom | Concepts::AtomReference] other_atom the second
      #   comparable atom
      # @return [Boolean] are different or not
      def different_by?(method, other, own_atom, other_atom)
        srs, ors = send(method, own_atom), other.send(method, other_atom)
        !lists_are_identical?(srs, ors, &:==)
      end

      # Checks that bonds of both atom have same relations sets
      # @param [DependentBaseSpec | DependentSpecificSpec] other same as #- argument
      # @param [Concepts::SpecificAtom | Concepts::Atom | Concepts::AtomReference]
      #   own_atom same as #different_by? argument
      # @param [Concepts::Atom | Concepts::AtomReference] other_atom same as
      #   #different_by? argument
      # @return [Boolean] are different or not
      def different_used_relations?(*args)
        different_by?(:used_relations_of, *args)
      end

      # Checks whether the atom is used in current links
      # @param [Array] used_in_mirror the atoms which was mapped to atoms of smallest
      #   spec
      # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
      #   atom the checkable atom
      # @return [Boolean] is used or not
      def used?(used_in_mirror, atom)
        (links.keys - used_in_mirror).any? do |a|
          links[a].any? do |neighbour, r|
            neighbour == atom && !excess_position?(r, atom, a)
          end
        end
      end

      # Checks that passed relation is position and that it is excess
      # @param [Concepts::Bond | Concepts::NoBond] relation which will checked
      # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
      #   first checking atom
      # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
      #   second checking atom
      def excess_position?(relation, first, second)
        relation.relation? && !relation.bond? &&
          excess_position_between?(first, second)
      end

      # Checks that current specie have excess position between passed atoms
      # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
      #   first checking atom
      # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
      #   second checking atom
      # @return [Boolean] has excess poosition or not
      def excess_position_between?(first, second)
        @@_eps_cache ||= {}
        key = [first, second]
        return @@_eps_cache[key] if @@_eps_cache.include?(key)

        unless first.lattice == second.lattice
          raise 'Wrong position between atoms that belongs to different lattices'
        end

        crystal = first.lattice.instance
        result = !!crystal.position_between(first, second, links)
        @@_eps_cache[key] = @@_eps_cache[[second, first]] = result
      end

      # Merges collected references to previous references
      # @param [Hash] prev_refs the previous collected references from some spec
      #   residual; each value of hash should be an array
      # @return [Hash] collected_refs the references which was collecected in
      #   difference operation
      # @return [Hash] the merging result where each value is list of possible values
      def merge(prev_refs, collected_refs)
        collected_refs.each_with_object(prev_refs.dup) do |(k, v), result|
          if result[k]
            result[k] << v
          else
            result[k] = [v]
          end
        end
      end
    end

  end
end
