module VersatileDiamond
  module Organizers

    # Contain some specific spec and set of dependent specs
    class DependentSpecificSpec < DependentSpec
      include Module::ListsComparer
      include MultiChildrenSpec
      include ResidualContainerSpec

      def_delegators :@spec, :reduced, :could_be_reduced?, :specific_atoms,
        :external_bonds, :links, :gas?

      attr_reader :parent

      # Initializes dependent specific spec by specific spec
      # @param [Concepts::SpecificSpec] specific_spec
      def initialize(specific_spec)
        super
        @parent = nil
        @child, @reaction, @there = nil
      end

      # Gets base spec for wrapped specific spec
      # @return [Concepts::Spec] the base spec
      def base_spec
        spec.spec
      end

      # Gets name of base spec
      # @return [Symbol] the name of base spec
      def base_name
        base_spec.name
      end

      # Contain specific atoms or not
      # @return [Boolean] contain or not
      def specific?
        !specific_atoms.empty?
      end

      # Sets the parent of spec and store self to it parent
      # @param [DependentBaseSpec | DependentSpecificSpec] parent the real parent of
      #   current spec
      # @raise [RuntimeError] if parent already set
      def store_parent(parent)
        raise 'Parent already exists' if @parent
        @parent = parent
        parent.store_child(self)
        store_rest(self - parent)
      end

      # Clears the parent of spec
      # @param [DependentBaseSpec | DependentSpecificSpec] parent the real parent of
      #   current spec
      # @raise [RuntimeError] if parent is not set
      def remove_parent(parent)
        raise 'Parent is not exists' unless @parent
        raise 'Removable parent is not same as passed' unless @parent == parent
        @parent = @rest = nil
      end

      # Reassigns parent and accumulate the residual between old parent and new parent
      # @param [DependentBaseSpec] new_parent the new parent which will be stored
      def replace_parent(new_parent)
        raise 'Previous parent is not exists' unless @parent

        unless new_parent.is_a?(DependentBaseSpec)
          raise ArgumentError, 'Passed parent is not DependentBaseSpec'
        end
        replace_base_spec(new_parent)

        remove_parent(parent)
        store_parent(new_parent)
      end

      # Makes difference between other dependent spec
      # @param [DependentBaseSpec | DependentSpecificSpec] other the subtrahend spec
      # @return [SpecResidual] the residual of difference operation
      def - (other)
        links_hash = {}
        replaced_atoms = {}
        mirror = mirror_to(other)

        # the first pairs should targets on not mapped atoms (if other links size
        # less than links size of current specie)
        pairs_from(mirror).each do |curr_atom, other_atom|
          if replaced_atoms[curr_atom] || !other_atom
            key =
              replaced_atoms[curr_atom] ||= replace_atom(other, curr_atom, other_atom)
            links_hash[key] = ref_to_links_of(other, curr_atom, mirror, replaced_atoms)
          elsif are_atoms_different?(other, curr_atom, other_atom)
            key = Concepts::AtomReference.new(spec, spec.keyname(curr_atom))
            links_hash[key] = []
          end
        end

        SpecResidual.new(links_hash)
      end

      # Provides relations of atom in current specie
      # @param [Concepts::Atom | Concepts::AtomRelation] atom for which relations will
      #   be got
      # @return [Array] the array of atom relations
      def relations_of(atom)
        relations = atom.relations_in(self)
        syms = relations.select { |r| r.is_a?(Symbol) }
        (relations - syms).map(&:last) + syms
      end

      # Organize dependencies from another similar species. Dependencies set if
      # similar spec has less specific atoms and existed specific atoms is same
      # in both specs. Moreover, activated atoms have a greater advantage.
      #
      # @param [Hash] base_hash the cache where keys are names and values are
      #   wrapped base specs
      # @param [Array] similar_specs the array of specs where each spec has
      #   same basic spec
      def organize_dependencies!(base_cache, similar_specs)
        similar_specs = similar_specs.reject do |s|
          s == self || s.size > size
        end

        similar_specs.sort_by! { |ss| -ss.size }

        parent = similar_specs.find do |ss|
          ss.specific_atoms.all? do |keyname, atom|
            a = specific_atoms[keyname]
            a && is?(a, atom)
          end
        end

        store_parent(parent || base_cache[base_name])
      end

      # Counts number of specific atoms
      # @return [Integer] the number of specific atoms
      def size
        specific_atoms.size * 8 + dangling_bonds_num * 2 + relevants_num
      end

      def to_s
        result = "(#{name}, "
        result += parent ? "[#{parent.name}], " : '[], '
        result + "[#{children.map(&:to_s).join(' ')}])"
      end

      def inspect
        to_s
      end

    protected

      # Counts the sum of active bonds and monovalent atoms
      # @return [Integer] sum of dangling bonds
      def dangling_bonds_num
        spec.active_bonds_num + monovalents_num
      end

      # Replaces base specie of current wrapped specific specie
      # @param [DependentBaseSpec] new_base the new base specie
      def replace_base_spec(new_base)
        children.each { |child| child.replace_base_spec(new_base) }
        spec.replace_base_spec(new_base.spec)
        rest.links.keys.map(&:update_keyname) if rest
      end

    private

      # Gets a mirror to another dependent spec
      # @param [DependentBaseSpec | DependentSpecificSpec] other the specie atom of
      #   which will be mirrored from current spec atoms
      # @return [Hash] the mirror
      def mirror_to(other)
        spec_atoms_comparer = -> _, _, a1, a2 { a1.original_same?(a2) }
        intersec = Mcs::SpeciesComparator.first_general_intersec(
          spec, other.spec, &spec_atoms_comparer)
        raise 'Intersec is not full' if other.links.size != intersec.size

        Hash[intersec.to_a]
      end

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
        different_relations?(other, spec_atom, base_atom) ||
          !base_atom.diff(spec_atom).empty?
      end

      # Checks that relations of both atom have same relations sets
      # @param [DependentBaseSpec | DependentSpecificSpec] other same as #- argument
      # @param [Concepts::SpecificAtom | Concepts::Atom | Concepts::AtomReference]
      #   spec_atom same as #are_atoms_different? argument
      # @param [Concepts::Atom | Concepts::AtomReference] base_atom same as
      #   #are_atoms_different? argument
      # @return [Boolean] are different or not
      def different_relations?(other, spec_atom, base_atom)
        self_rel, other_rel = relations_of(spec_atom), other.relations_of(base_atom)
        !lists_are_identical?(self_rel, other_rel, &:==)
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
          sp = other.spec
          ref = Concepts::AtomReference.new(sp, sp.keyname(other_atom))

          own_relevant = !own_atom.relevants.empty?
          if own_relevant && are_atoms_different?(other, own_atom, other_atom)
            Concepts::SpecificAtom.new(ref, ancestor: own_atom)
          else
            ref
          end
        end
      end

      # Counts the sum of monovalent atoms at specific atoms
      # @return [Integer] sum of monovalent atoms
      def monovalents_num
        specific_atoms.reduce(0) { |acc, (_, atom)| acc + atom.monovalents.size }
      end

      # Counts the sum of relative states of atoms
      # @return [Integer] sum of relative states
      def relevants_num
        specific_atoms.reduce(0) { |acc, (_, atom)| acc + atom.relevants.size }
      end

      # Compares two specific atoms and checks that smallest is less than
      # bigger
      #
      # @param [Concepts::SpecificAtom] bigger probably the bigger atom
      # @param [Concepts::SpecificAtom] smallest probably the smallest atom
      # @return [Boolean] smallest is less or not
      def is?(bigger, smallest)
        same_danglings?(bigger, smallest) && same_relevants?(bigger, smallest)
      end

      # Checks that smallest atom contain less dangling states than bigger
      # @param [Concepts::SpecificAtom] bigger see at #is? same argument
      # @param [Concepts::SpecificAtom] smallest see at #is? same argument
      # @return [Boolean] contain or not
      def same_danglings?(bigger, smallest)
        smallest.actives <= bigger.actives &&
          (smallest.monovalents - bigger.monovalents).empty?
      end

      # Checks that smallest atom contain less relevant states than bigger
      # @param [Concepts::SpecificAtom] bigger see at #is? same argument
      # @param [Concepts::SpecificAtom] smallest see at #is? same argument
      # @return [Boolean] contain or not
      def same_relevants?(bigger, smallest)
        diff = smallest.relevants - bigger.relevants
        diff.empty? || (diff == [:incoherent] && bigger.size > smallest.size &&
          (!bigger.monovalents.empty? || bigger.actives > 0))
      end
    end

  end
end
