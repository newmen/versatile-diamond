module VersatileDiamond
  module Organizers

    # Contain some specific spec and set of dependent specs
    class DependentSpecificSpec < DependentWrappedSpec

      def_delegators :@spec, :reduced, :could_be_reduced?

      # Gets name of base spec
      # @return [Symbol] the name of base spec
      def base_name
        spec.spec.name
      end

      # Contain specific atoms or not
      # @return [Boolean] contain or not
      # @override
      def specific?
        !specific_atoms.empty?
      end

      # Replaces base specie of current wrapped specific specie
      # @param [DependentBaseSpec] new_base the new base specie
      def replace_base_spec(new_base)
        update_links(new_base)
        spec.replace_base_spec(new_base.spec)

        if @rest
          store_rest(self - new_base)
          children.each { |child| child.replace_base_spec(new_base) }
        end
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
        similar_specs = similar_specs.reject { |s| s == self || self < s }
        similar_specs.sort! { |a, b| b <=> a }

        parent = similar_specs.find do |possible_parent|
          possible_parent.specific_atoms.all? do |keyname, parent_atom|
            child_atom = specific_atoms[keyname]
            child_atom && is?(possible_parent, child_atom, parent_atom)
          end
        end

        store_rest(self - (parent || base_cache[base_name]))
      end

      # Gets a mirror to another dependent spec
      # @param [DependentBaseSpec | DependentSpecificSpec] other the specie atom of
      #   which will be mirrored from current spec atoms
      # @return [Hash] the mirror
      # @override
      def mirror_to(other)
        spec_atoms_comparer = -> _, _, a1, a2 { a1.original_same?(a2) }
        intersec = Mcs::SpeciesComparator.first_general_intersec(
          spec, other.spec, &spec_atoms_comparer)
        raise 'Intersec is not full' unless other.links.size == intersec.size
        # the raise should be because this situation can't be presented

        Hash[intersec.to_a]
      end

    protected

      def_delegator :@spec, :specific_atoms

      # Counts the sum of active bonds and monovalent atoms
      # @return [Integer] sum of dangling bonds
      def dangling_bonds_num
        spec.active_bonds_num + monovalents_num
      end

      # Counts the sum of relative states of atoms
      # @return [Integer] sum of relative states
      def relevants_num
        specific_atoms.reduce(0) { |acc, (_, atom)| acc + atom.relevants.size }
      end

    private

      # Provides additional comparation by internal properties
      # @param [Minuend] other see at #<=> same argument
      # @return [Integer] the result of comparation
      # @override
      def order_relations(other, &block)
        super(other) do
          order(self, other, :specific_atoms, :size) do
            order(self, other, :dangling_bonds_num) do
              order(self, other, :relevants_num, &block)
            end
          end
        end
      end

      # Updates links by new base specie. Replaces correspond atoms in internal
      # links graph
      #
      # @param [DependentBaseSpec] new_base the new base specie from which atoms will
      #   be used instead atoms of old base specie
      def update_links(new_base)
        mirror = DependentBaseSpec.new(spec.spec).mirror_to(new_base)

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

      # Compares two specific atoms and checks that own atom could include other atom
      # @param [DependentSpecificSpec] other
      # @param [Concepts::SpecificAtom] own_atom of current spec
      # @param [Concepts::SpecificAtom] other_atom of passed spec
      # @return [Boolean] is own include other or not
      def is?(other, own_atom, other_atom)
        own_prop = AtomProperties.new(self, own_atom)
        other_prop = AtomProperties.new(other, other_atom)
        own_prop.include?(other_prop)
      end
    end

  end
end
