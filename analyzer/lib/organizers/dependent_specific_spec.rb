module VersatileDiamond
  module Organizers

    # Contain some specific spec and set of dependent specs
    class DependentSpecificSpec < DependentWrappedSpec

      def_delegators :@spec, :reduced, :could_be_reduced?, :specific_atoms
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
      # @override
      def specific?
        !specific_atoms.empty?
      end

      # Provides compatibility with dependent base spec
      # @return [Array] the array with one item which is current parent if it presented
      def parents
        parent ? [parent] : []
      end

      # Sets the parent of spec and store self to it parent
      # @param [DependentBaseSpec | DependentSpecificSpec] parent the real parent of
      #   current spec
      # @raise [RuntimeError] if parent already set
      def store_parent(parent)
        raise 'Parent already exists' if @parent
        return unless parent # TODO: it's right?
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
        update_links(new_base)
        spec.replace_base_spec(new_base.spec)
        children.each { |child| child.replace_base_spec(new_base) }
      end

    private

      # Gets a mirror to another dependent spec
      # @param [DependentBaseSpec | DependentSpecificSpec] other the specie atom of
      #   which will be mirrored from current spec atoms
      # @return [Hash] the mirror
      # @override
      def mirror_to(other)
        spec_atoms_comparer = -> _, _, a1, a2 { a1.original_same?(a2) }
        intersec = Mcs::SpeciesComparator.first_general_intersec(
          spec, other.spec, &spec_atoms_comparer)
        raise 'Intersec is not full' if other.links.size != intersec.size
        # the raise should be because this situation can't be presented

        Hash[intersec.to_a]
      end

      # Updates links by new base specie. Replaces correspond atoms in internal
      # links graph
      #
      # @param [DependentBaseSpec] new_base the new base specie from which atoms will
      #   be used instead atoms of old base specie
      def update_links(new_base)
        mirror = DependentBaseSpec.new(base_spec).mirror_to(new_base)

        update_atoms(mirror)
        update_relations(mirror)
      end

      # Updates keys of internal links graph
      # @param [Hash] mirror where keys are atoms of old base specie and values are
      #   atoms of new base specie
      def update_atoms(mirror)
        links.keys.each do |atom|
          other_atom = mirror[atom]
          links[other_atom] = links.delete(atom) if other_atom
        end
      end

      # Updates internal atoms in relations in links graph
      # @param [Hash] mirror where keys are atoms of old base specie and values are
      #   atoms of new base specie
      def update_relations(mirror)
        links.values.each do |relations|
          relations.map! do |atom, relation|
            [mirror[atom] || atom, relation]
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
