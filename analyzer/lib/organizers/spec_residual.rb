module VersatileDiamond
  module Organizers

    # Contain some residual of find diff between base species
    class SpecResidual
      include Minuend

      class << self
        # Gets empty residual instance
        # @param [DependentWrappedSpec] owner see at #new same argument
        # @return [SpecResidual] the empty residual instance
        def empty(owner)
          new(owner, owner.links, {})
        end
      end

      attr_reader :links

      # Initialize residual by hash of links and residual border atoms
      # @param [DependentWrappedSpec] owner of current instance
      # @param [Hash] links the links between some atoms
      # @param [hash] atoms_to_parents the mirror of owner atoms to parent specs
      def initialize(owner, links, atoms_to_parents)
        @owner = owner
        @links = links
        @atoms_to_parents = atoms_to_parents
      end

      # Makes correct difference with other spec
      # @param [DependentWrappedSpec] other see at #super same argument
      # @return [SpecResidual] spec residual that contains current instance and
      #   difference operation result
      # @override
      def - (other)
        diff = super(other)
        return nil unless diff

        full_atoms_to_parents = merge(@atoms_to_parents, diff.atoms_to_parents)
        self.class.new(owner, diff.links, full_atoms_to_parents)
      end

      # Gets all stored parents
      # @return [Array] the list of proxy parent species
      def parents
        result = atoms_to_parents.values.reduce(:+)
        result ? result.uniq : []
      end

      # Checks that other spec has same border atoms and links between them
      # @param [DependentBaseSpec | SpecResidual] other the comparable spec
      # @return [Boolean] same or not
      def same?(other)
        return false unless links.size == other.links.size
        return false unless self.class == other.class && owner.same?(other.owner)

        intersec = mirror_to(other)
        intersec.size == links.size && intersec.all? do |a, b|
          !different_relations?(other, a, b)
        end
      end

    protected

      attr_reader :atoms_to_parents, :owner

    private

      # Changes comparison behavior for more optimal base specs spliting
      # @param [Minuend] other see at #<=> same argument
      # @return [Integer] the result of comparation
      # @override
      def order_relations(other, &block)
        order(other, self, :relations_num, &block)
      end

      # Checks that relations of both atom have same sets
      # @param [DependentBaseSpec | DependentSpecificSpec] other same as #- argument
      # @param [Concepts::SpecificAtom | Concepts::Atom | Concepts::AtomReference]
      #   spec_atom same as Minuend#different_by? argument
      # @param [Concepts::Atom | Concepts::AtomReference] base_atom same as
      #   Minuend#different_by? argument
      # @return [Boolean] are different or not
      def different_relations?(*args)
        different_by?(:relations_of, *args)
      end

      # Merges collected references of atoms to parent specs
      # @param [Hash] prev_refs the previous collected references
      # @return [Hash] new_refs the references which was collecected in difference
      #   operation
      # @return [Hash] the merging result where each value is list of possible values
      def merge(prev_refs, new_refs)
        new_refs.each_with_object(prev_refs.dup) do |(a, ps), result|
          if result[a]
            result[a] += ps
          else
            result[a] = ps
          end
        end
      end

      # Delegates to original links of owner spec
      # @return [Hash] the links between atoms of owner spec
      def original_links
        owner.original_links
      end

      # Provides links that will be cleaned by #clean_links
      # @return [Hash] the links which will be cleaned
      def cleanable_links
        links
      end
    end

  end
end
