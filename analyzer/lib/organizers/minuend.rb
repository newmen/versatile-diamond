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
      def links_size
        links.size
      end

      # Counts the atom reference instances
      # @return [Integer] the number of atom references
      def refs_num
        links.keys.select(&:reference?).size
      end

      # Makes residual of difference between top and possible parent
      # @param [DependentBaseSpec | DependentSpecificSpec] other the subtrahend spec
      # @return [SpecResidual] the residual of diference between arguments or nil if
      #   it doesn't exist
      def - (other)
        mirror = mirror_to(other)
        return nil if mirror.empty? || other.links.size != mirror.size

        links_hash = {}
        replaced_atoms = {}

        # the first pairs should targets on not mapped atoms (if other links size
        # less than links size of current specie)
        pairs_from(mirror).each do |curr_atom, other_atom|
          if replaced_atoms[curr_atom] || !other_atom
            key =
              replaced_atoms[curr_atom] ||= replace_atom(other, curr_atom, other_atom)
            links_hash[key] = ref_to_links_of(other, curr_atom, mirror, replaced_atoms)
          elsif are_atoms_different?(other, curr_atom, other_atom)
            key = Concepts::AtomReference.new(self, curr_atom)
            links_hash[key] = []
          end
        end

        SpecResidual.new(links_hash)
      end


      # Provides relations of atom in current resudual
      # @param [Concepts::Atom | Concepts::AtomRelation] atom for which relations will
      #   be got
      # @return [Array] the array of atom relations
      def relations_of(atom)
        atom.relations_in(self).map(&:last)
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
        opts = { collaps_multi_bond: true }
        first = Mcs::SpeciesComparator.first_general_intersec(self, spec, opts)
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
      #   spec_atom the major of comparable atoms
      # @param [Concepts::Atom | Concepts::AtomReference] base_atom the second
      #   comparable atom
      # @return [Boolean] are different or not
      def are_atoms_different?(other, spec_atom, base_atom)
        different_bonds?(other, spec_atom, base_atom) ||
          !base_atom.diff(spec_atom).empty?
      end

      # Checks that relations gotten by method of both atom have same relations sets
      # @param [Symbol] method name which will called
      # @param [DependentBaseSpec | DependentSpecificSpec] other same as #- argument
      # @param [Concepts::SpecificAtom | Concepts::Atom | Concepts::AtomReference]
      #   spec_atom same as #are_atoms_different? argument
      # @param [Concepts::Atom | Concepts::AtomReference] base_atom same as
      #   #are_atoms_different? argument
      # @return [Boolean] are different or not
      def different_by?(method, other, spec_atom, base_atom)
        srs, ors = send(method, spec_atom), other.send(method, base_atom)
        !lists_are_identical?(srs, ors, &:==)
      end

      # Checks that bonds of both atom have same relations sets
      # @param [DependentBaseSpec | DependentSpecificSpec] other same as #- argument
      # @param [Concepts::SpecificAtom | Concepts::Atom | Concepts::AtomReference]
      #   spec_atom same as #are_atoms_different? argument
      # @param [Concepts::Atom | Concepts::AtomReference] base_atom same as
      #   #are_atoms_different? argument
      # @return [Boolean] are different or not
      def different_bonds?(*args)
        different_by?(:bonds_of, *args)
      end

      # Duplicates links of own atom and exchange them to correct correspond atoms
      # @param [DependentBaseSpec | DependentSpecificSpec] other the subtrahend spec
      # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
      #   own_atom the atom from current spec for which links are copied
      # @param [Hash] mirror of atom from current spec to subtrahend spec
      # @param [Hash] cache the changable cache of exchanged atoms
      # @return [Array] the array of copied links of own atoms
      def ref_to_links_of(other, own_atom, mirror, cache)
        different_links =
          if mirror[own_atom]
            links[own_atom].select do |bonded_atom, _|
              other_atom = mirror[bonded_atom]
              !other_atom || are_atoms_different?(other, bonded_atom, other_atom)
            end
          else
            links[own_atom]
          end

        different_links.map do |bonded_atom, link|
          cache[bonded_atom] ||= replace_atom(other, bonded_atom, mirror[bonded_atom])
          [cache[bonded_atom], link]
        end
      end

      # Checks and replace some atom to correspond reference
      # @param [DependentBaseSpec | DependentSpecificSpec] other see at
      #   #ref_to_links_of same argument
      # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
      #   own_atom see at #ref_to_links_of same argument
      # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
      #   other_atom the atom from other spec
      # @return [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
      #   the correspond atom or reference
      def replace_atom(other, own_atom, other_atom)
        if !other_atom
          own_atom
        else
          ref = Concepts::AtomReference.new(other, other_atom)
          select_atom(other, own_atom, other_atom, ref)
        end
      end

      # Selects some atom from passed instances
      # @param [DependentBaseSpec | DependentSpecificSpec] other see at
      #   #ref_to_links_of same argument
      # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
      #   own_atom see at #ref_to_links_of same argument
      # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
      #   other_atom the atom from other spec
      # @param [Concepts::AtomReference] ref the reference to atom of other specie
      # @return [Concepts::Atom | Concepts::AtomReference] selected concept
      def select_atom(other, own_atom, other_atom, ref)
        if are_atoms_different?(other, own_atom, other_atom)
          ref
        elsif !other_atom.reference?
          other_atom
        else
          without_refs = other.closed
          mirror = other.mirror_to(without_refs)
          Concepts::AtomReference.new(without_refs, mirror[other_atom])
        end
      end
    end

  end
end
