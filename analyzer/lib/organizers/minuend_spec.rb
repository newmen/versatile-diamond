module VersatileDiamond
  module Organizers

    # Provides method for minuend behavior
    module MinuendSpec
      include Modules::OrderProvider
      include Modules::ProcsReducer
      include Organizers::LinksCleaner
      include Organizers::Minuend

      # Compares two minuend instances
      # @param [Minuend] other the comparable minuend instance
      # @return [Integer] the result of comparation
      def <=>(other)
        compare_with(other)
      end

      # Checks that current instance is less than other
      # @param [Minuend] other the comparable minuend instance
      # @return [Boolean] is less or not
      def <(other)
        compare_with(other, strong_types_order: false) < 0
      end

      # Checks that current instance is less than other or equal
      # @param [Minuend] other the comparable minuend instance
      # @return [Boolean] is less or equal or not
      def <=(other)
        self == other || self < other
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
        Mcs::SpeciesComparator.make_mirror(self, spec)
      end


    protected

      # Counts the relations number in current links
      # @return [Integer] the number of relations
      def relations_num
        erase_excess_positions(links).values.map(&:size).reduce(:+)
      end

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

      # Compares two minuend instances
      # @param [Minuend] other the comparable minuend instance
      # @param [Hash] kwargs
      # @return [Integer] the result of comparation
      def compare_with(other, **kwargs)
        core_proc = -> { comparing_core(other) }
        inlay_procs(core_proc) do |nest|
          inlay_orders(nest, other, **kwargs)
        end
      end

      # Provides the first checking order between self and other minuends
      # @param [Proc] nest to which the call will be nested
      # @param [Minuend] other comparing item
      # @option [Boolean] :strong_types_order is the flag which if set then types info
      #   also used for ordering
      def inlay_orders(nest, other, strong_types_order: true)
        nest[:order_classes, other] if strong_types_order
        nest[:order, self, other, :relations_num]
        nest[:order, self, other, :links, :size]
      end

      # Provides the lowest level of comparing two minuend instances
      # @param [MinuendSpec] other comparing instance
      # @return [Integer] the result of comparation
      def comparing_core(other)
        order(self, other, :parents, :size) do
          order(self, other, :name)
        end
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

      # Gets the links without excess positions
      # @param [Hash] links between atoms
      # @return [Hash] the links without excess positions
      # @override
      def erase_excess_positions(links)
        erase_excess_relations_if(super(links)) do |_, v, w|
          excess_parent_relation?(v, w)
        end
      end

      # Checks that passed relation between atoms is not excess
      # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
      #   neighbour_key the neighbour key of iterable key
      # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
      #   checking_key the key which checks that it used
      # @param [Concepts::Bond] relation between iterable key and neighbour key
      # @return [Boolean] is realy used checking key or not
      def excess_neighbour?(neighbour_key, checking_key, relation)
        excess_position?(relation, checking_key, neighbour_key)
      end
    end

  end
end
