module VersatileDiamond
  module Organizers

    # Provides method for minuend behavior
    module Minuend
      include Modules::ListsComparer
      include Modules::OrderProvider
      include Organizers::LinksCleaner

      # Compares two minuend instances
      # @param [Minuend] other the comparable minuend instance
      # @return [Integer] the result of comparation
      def <=> (other)
        order(self, other, :links, :size) do
          order_classes(other) do
            order_relations(other) do
              parents.size <=> other.parents.size
            end
          end
        end
      end

      # Checks that current instance is less than other
      # @param [Minuend] other the comparable minuend instance
      # @return [Boolean] is less or not
      def < (other)
        (self <=> other) < 0
      end

      # Checks that current instance is less than other or equal
      # @param [Minuend] other the comparable minuend instance
      # @return [Boolean] is less or equal or not
      def <= (other)
        self == other || self < other
      end

      # Makes residual of difference between top and possible parent
      # @param [DependentBaseSpec | DependentSpecificSpec] other the subtrahend spec
      # @return [SpecResidual] the residual of diference between arguments or nil if
      #   it doesn't exist
      def - (other)
        mirror = mirror_to(other)
        return nil if other.links.size != mirror.size

        proxy = ProxyParentSpec.new(other, owner, mirror)

        residuals = {}
        atoms_to_parents = {}
        pairs_from(mirror).each do |own_atom, other_atom|
          unless other_atom
            residuals[own_atom] = links[own_atom] # <-- same as bottom
            next
          end

          is_diff = different_used_relations?(other, own_atom, other_atom) ||
            used?(mirror.keys, own_atom)

          if is_diff
            residuals[own_atom] = links[own_atom] # <-- same as top
            atoms_to_parents[own_atom] = [proxy]
          end
        end

        SpecResidual.new(owner, residuals, atoms_to_parents)
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
        @_clean_links ||= erase_excess_positions(cleanable_links)
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

      # Counts the relations number in current links
      # @return [Integer] the number of relations
      def relations_num
        links.values.map(&:size).reduce(:+)
      end

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

      # Provides comparison by class of each instance
      # @param [Minuend] other see at #<=> same argument
      # @return [Integer] the result of comparation
      def order_classes(other, &block)
        typed_order(self, other, DependentSpecificSpec) do
          typed_order(self, other, DependentBaseSpec) do
            typed_order(self, other, SpecResidual, &block)
          end
        end
      end

      # Provides comparison by number of relations
      # @param [Minuend] other see at #<=> same argument
      # @return [Integer] the result of comparation
      def order_relations(other, &block)
        order(self, other, :relations_num, &block)
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
    end

  end
end
