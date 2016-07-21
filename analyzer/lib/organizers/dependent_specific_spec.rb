module VersatileDiamond
  using Patches::RichArray

  module Organizers

    # Contain some specific spec and set of dependent specs
    class DependentSpecificSpec < DependentWrappedSpec
      include Modules::GraphDupper

      def_delegators :spec, :reduced, :could_be_reduced?

      # Gets name of base spec
      # @return [Symbol] the name of base spec
      def base_name
        spec.spec.name
      end

      # Gets anchors of specific specie
      # @return [Array] the array of anchor atoms
      # @override
      def anchors
        @_anchors ||=
          if source?
            atoms
          else
            self_ptas = specific_props_from(self).zip(specific_atoms.values)
            parent_props = specific_props_from(parents.first)
            variant = parent_props.reduce(self_ptas) do |acc, pr|
              result = acc.dup
              result.delete_one { |p, _| pr == p } ? result : acc
            end
            variant.map(&:last)
          end
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

        store_rest(self - new_base)
        children.each { |child| child.replace_base_spec(new_base) }
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
        small_specs = similar_specs.uniq.reject { |s| s == self || self < s }
        small_specs.sort! { |a, b| b <=> a }

        self_props = specific_props_from(self)
        props_to_atoms = self_props.zip(specific_atoms.values)
        parent = small_specs.find do |possible_parent|
          pp_props = specific_props_from(possible_parent)
          are_props_identical = lists_are_identical?(self_props, pp_props, &:include?)
          anchor_props = self_props - pp_props
          next if !are_props_identical && anchor_props == self_props

          rest_props = self_props - anchor_props
          rest_props.empty? || pp_props.permutation.any? do |pps|
            total = anchor_props + rest_props
            pps.all? do |ap|
              total.delete_one { |rp| rp.include?(ap) }
            end
          end
        end

        parent ||= base_cache[base_name]
        store_rest(self - parent) if parent
      end

      # Gets a mirror to another dependent spec
      # @param [DependentBaseSpec | DependentSpecificSpec] other the specie atom of
      #   which will be mirrored from current spec atoms
      # @return [Hash] the mirror
      # @override
      def mirror_to(other)
        Mcs::SpeciesComparator.make_mirror(spec, other.spec) do |_, _, a1, a2|
          a1.original_same?(a2) # TODO: same as in SpecAtomSwapper
        end
      end

    protected

      def_delegators :@spec, :specific_atoms, :monovalents_num

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
      # @param [MinuendSpec] other see at #<=> same argument
      # @return [Integer] the result of comparation
      # @override
      def inlay_orders(nest, other, **kwargs)
        super(nest, other, **kwargs)
        nest[:order, self, other, :specific_atoms, :size]
        nest[:order, self, other, :dangling_bonds_num]
        nest[:order, self, other, :relevants_num]
      end

      # Updates links by new base specie. Replaces correspond atoms in internal
      # links graph
      #
      # @param [DependentBaseSpec] new_base the new base specie from which atoms will
      #   be used instead atoms of old base specie
      def update_links(new_base)
        mirror = DependentBaseSpec.new(spec.spec).mirror_to(new_base)

        update_reactions(mirror)
        update_theres(mirror)
        update_atoms(mirror)
      end

      # Updates atoms that uses in reactions which depends from current spec
      # @param [Hash] mirror where keys are atoms of old base specie and values are
      #   atoms of new base specie
      def update_reactions(mirror)
        reactions.each do |reaction|
          mirror.each { |from, to| reaction.swap_atom(spec, from, to) }
        end
      end

      # Updates atoms that uses in there objects as environment atoms
      # @param [Hash] mirror where keys are atoms of old base specie and values are
      #   atoms of new base specie
      def update_theres(mirror)
        theres.each do |there|
          mirror.each { |from, to| there.swap_env_atom(spec, from, to) }
        end
      end

      # Updates internal atoms in relations in links graph
      # @param [Hash] mirror where keys are atoms of old base specie and values are
      #   atoms of new base specie
      def update_atoms(mirror)
        @links = dup_graph(@links) { |atom| mirror[atom] || atom }
      end

      # @param [DependentSpecificSpec] spec
      # @return [Array]
      def specific_props_from(spec)
        spec.specific_atoms.map { |_, atom| AtomProperties.new(spec, atom) }
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
