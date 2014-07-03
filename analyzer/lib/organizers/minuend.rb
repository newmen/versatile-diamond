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

      # Counts the atom reference instances
      # @return [Integer] the number of atom references
      def relations_num
        links.values.map(&:size).reduce(:+)
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

      # Makes residual of difference between top and possible parent
      # @param [DependentBaseSpec | DependentSpecificSpec] other the subtrahend spec
      # @return [SpecResidual] the residual of diference between arguments or nil if
      #   it doesn't exist
      def - (other)
        mirror = mirror_to(other)
        return nil if mirror.empty? || other.links.size != mirror.size

        result = {}
        pairs_from(mirror).each do |own_atom, other_atom|
          if !other_atom || different_bonds?(other, own_atom, other_atom) ||
            used?(mirror.keys, own_atom)

            result[own_atom] = links[own_atom]
          end
        end

        SpecResidual.new(result)
      end

    protected

      # Rejects position relations
      # @param [Atom] atom see at #relations_of same argument
      # @return [Array] the array of relations without position relations
      def bonds_of(atom)
        relations_of(atom).reject { |r| r.is_a?(Concepts::Position) }
      end

      # Finds first intersec with some spec
      # @param [DependentBaseSpec] spec the checkable specie
      # @return [Array] the array of each pair of intersection or nil if intersection
      #   have not fond
      def mirror_to(spec)
        first = Mcs::SpeciesComparator.first_general_intersec(self, spec)
        first && Hash[first.to_a]
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

      # Checks that atoms are different
      # @param [DependentBaseSpec | DependentSpecificSpec] other same as #- argument
      # @param [Concepts::SpecificAtom | Concepts::Atom | Concepts::AtomReference]
      #   own_atom the major of comparable atoms
      # @param [Concepts::Atom | Concepts::AtomReference] other_atom the second
      #   comparable atom
      # @return [Boolean] are different or not
      def atoms_different?(other, own_atom, other_atom)
        different_bonds?(other, own_atom, other_atom) ||
          !other_atom.diff(own_atom).empty?
      end

      # Checks that relations gotten by method of both atom have same relations sets
      # @param [Symbol] method name which will called
      # @param [DependentBaseSpec | DependentSpecificSpec] other same as #- argument
      # @param [Concepts::SpecificAtom | Concepts::Atom | Concepts::AtomReference]
      #   own_atom same as #atoms_different? argument
      # @param [Concepts::Atom | Concepts::AtomReference] other_atom same as
      #   #atoms_different? argument
      # @return [Boolean] are different or not
      def different_by?(method, other, own_atom, other_atom)
        srs, ors = send(method, own_atom), other.send(method, other_atom)
        !lists_are_identical?(srs, ors, &:==)
      end

      # Checks that bonds of both atom have same relations sets
      # @param [DependentBaseSpec | DependentSpecificSpec] other same as #- argument
      # @param [Concepts::SpecificAtom | Concepts::Atom | Concepts::AtomReference]
      #   own_atom same as #atoms_different? argument
      # @param [Concepts::Atom | Concepts::AtomReference] other_atom same as
      #   #atoms_different? argument
      # @return [Boolean] are different or not
      def different_bonds?(*args)
        different_by?(:bonds_of, *args)
      end

      # Checks whether the atom used current links
      # @param [Array] used_in_mirror the atoms which was mapped to atoms of smallest
      #   spec
      # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
      #   atom the checkable atom
      # @return [Boolean] is used or not
      def used?(used_in_mirror, atom)
        (links.keys - used_in_mirror).any? do |a|
          links[a].any? do |neighbour, relation|
            neighbour == atom && !relation.is_a?(Concepts::Position)
          end
        end
      end
    end

  end
end
