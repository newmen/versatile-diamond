module VersatileDiamond
  module Organizers

    # Provides method for minuend behavior
    module MinuendSpec
      include Organizers::LinksCleaner
      include Organizers::Minuend

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
        Mcs::SpeciesComparator.make_mirror(self, spec)
      end

    protected

      # Gets the array of used relations without excess position relations
      # @param [Atom] atom see at #relations_of same argument
      # @return [Array] the array of relations without excess position relations
      def used_relations_of(atom)
        pairs = relations_of(atom, with_atoms: true).reject do |a, r|
          excess_position?(r, atom, a)
        end
        pairs.map(&:last)
      end

    private

      # Makes residual of difference between top and possible parent
      # @param [DependentBaseSpec | DependentSpecificSpec] other the subtrahend spec
      # @param [Hash] mirror from self to other spec
      # @return [SpecResidual] the residual of diference between arguments or nil if
      #   it doesn't exist
      def subtract(other, mirror)
        # the proxy should be maked just one time
        proxy = ProxyParentSpec.new(other, owner, mirror)

        atoms_to_parents = {}
        residuals = rest_links(other, mirror) do |own_atom|
          atoms_to_parents[own_atom] = [proxy]
        end

        SpecResidual.new(owner, residuals, atoms_to_parents)
      end

      # Provides the lowest level of comparing two minuend instances
      # @param [MinuendSpec] other comparing instance
      # @return [Proc] the core of comparison
      def comparing_core(other)
        -> { parents.size <=> other.parents.size }
      end

      # Provides comparison by class of each instance
      # @param [MinuendSpec] other see at #<=> same argument
      # @return [Integer] the result of comparation
      def order_classes(other, &block)
        typed_order(self, other, DependentSpecificSpec) do
          typed_order(self, other, DependentBaseSpec) do
            typed_order(self, other, SpecResidual, &block)
          end
        end
      end

      # Checks that passed neibhour key is the same as cheking key and relation between
      # them is not excess
      #
      # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
      #   iterable_key the key which was not mapped
      # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
      #   neighbour_key the neighbour key of iterable key
      # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
      #   checking_key the key which checks that it used
      # @param [Concepts::Bond] relation between iterable key and neighbour key
      # @return [Boolean] is realy used checking key or not
      def neighbour?(iterable_key, neighbour_key, checking_key, relation)
        neighbour_key == checking_key &&
          !excess_position?(relation, checking_key, iterable_key)
      end
    end

  end
end
