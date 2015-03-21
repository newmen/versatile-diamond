module VersatileDiamond
  module Organizers

    # Contain some residual of find diff between base species
    class SpecResidual
      include Modules::GraphDupper
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

      # Clones the current instance and replaces value of internal owner variable and
      # also changes internal hashes where uses the atoms of old owner spec
      #
      # @param [DependentWrappedSpec] owner the new value of owner variable
      # @param [Hash] mirror of old atoms to new atoms
      # @return [SpecResidual] the clone of current instance
      def clone_with_replace_by(owner, mirror)
        result = self.dup
        result.replace_owner(owner, mirror)
        result
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

      # Replaces the value of internal owner variable and change old owner atoms in
      # interhal hashes
      #
      # @param [DependentWrappedSpec] owner see at #clone_with_replace_by same argument
      # @param [Hash] mirror see at #clone_with_replace_by same argument
      def replace_owner(owner, mirror)
        @owner = owner
        @links = dup_graph(@links) { |a| mirror[a] }
        @atoms_to_parents = @atoms_to_parents.each_with_object({}) do |(a, ps), acc|
          acc[mirror[a]] = ps.map { |p| p.clone_with_replace_by(owner, mirror) }
        end
      end

    private

      # Changes comparison behavior for more optimal base specs spliting
      # @param [Minuend] other see at #<=> same argument
      # @return [Integer] the result of comparation
      # @override
      def order_relations(other, &block)
        order(other, self, :relations_num, &block)
      end

      # Gets the number of external bonds for comparing with dependent base spec
      # @return [Integer] the number of external bonds
      def external_bonds
        links.reduce(0) do |acc, (atom, rels)|
          acc + atom.valence + atom.additional_relations.size -
            rels.map(&:last).select(&:bond?).size
        end
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

      # Checks whether the atom is used in current residual
      # @param [Array] _ see at #super first argument
      # @param [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
      #   atom the checking atom
      # @return [Boolean] is atom used in current residual or not
      # @override
      def used?(_, atom)
        !!@atoms_to_parents[atom] || super
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
