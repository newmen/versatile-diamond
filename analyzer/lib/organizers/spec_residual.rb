module VersatileDiamond
  module Organizers

    # Contain some residual of find diff between base species
    class SpecResidual
      include Modules::GraphDupper
      include MinuendSpec

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
      # @param [Hash] atoms_to_parents the mirror of owner atoms to parent specs
      def initialize(owner, links, atoms_to_parents)
        @owner = owner
        @links = links
        @atoms_to_parents = atoms_to_parents

        @_clean_links = nil
      end

      # Gets fake name for strong ordering and tests farm
      # @return [Symbol]
      def name
        parents_names_suffix = parents.map(&:name).map(&:to_s).sort.join('%')
        :"__spec_residual_of_#{owner.name}_#{parents_names_suffix}"
      end

      # @param [Concepts::Atom...] atom
      # @return [Symbol]
      def keyname(atom)
        owner.spec.keyname(atom)
      end

      # Clones the current instance and replaces value of internal owner variable and
      # also changes internal hashes where uses the atoms of old owner spec
      #
      # @param [DependentWrappedSpec] other_owner the new value of owner variable
      # @param [Hash] mirror of old atoms to new atoms
      # @return [SpecResidual] the clone of current instance
      def clone_with_replace_by(other_owner, mirror)
        result = self.dup
        result.replace_owner!(other_owner, mirror)
        result
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
      # @param [DependentWrappedSpec] other_owner the new value of owner variable
      # @param [Hash] mirror see at #clone_with_replace_by same argument
      def replace_owner!(other_owner, mirror)
        @owner = other_owner
        @links = dup_graph(@links) { |a| mirror[a] }
        @atoms_to_parents = @atoms_to_parents.each_with_object({}) do |(a, ps), acc|
          acc[mirror[a]] = ps.map { |p| p.clone_with_replace_by(other_owner, mirror) }
        end
      end

    private

      # Makes correct difference with other spec
      # @return [SpecResidual] spec residual that contains current instance and
      #   difference operation result
      # @override
      def subtract(*)
        diff = super
        full_atoms_to_parents = merge(atoms_to_parents, diff.atoms_to_parents)
        self.class.new(diff.owner, diff.links, full_atoms_to_parents)
      end

      # In the case when comparing instances have the current class then checks number
      # of atoms which were not mapped with parent spec
      #
      # @param [Proc] nest to which the call will be nested
      # @param [Minuend] other comparing item
      # @option [Boolean] :strong_types_order is the flag which if set then types info
      #   also used for ordering
      # @override
      def inlay_orders(nest, other, **kwargs)
        nest[:order, self, other, :unmapped_num] if self.class == other.class
        super(nest, other, **kwargs)
      end

      # Counts number of linked atoms which are not mapped to parent species
      # @return [Integer] the nujmber of unmapped atoms
      def unmapped_num
        links.keys.reject(&atoms_to_parents.public_method(:[])).size
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
      #   spec_atom same as MinuendSpec#different_by? argument
      # @param [Concepts::Atom | Concepts::AtomReference] base_atom same as
      #   MinuendSpec#different_by? argument
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
        !!atoms_to_parents[atom] || super
      end

      # @param [Array] atoms
      # @return [Boolean]
      def excess_parent_relation?(*atoms)
        ps, qs = atoms.map(&atoms_to_parents.public_method(:[]))
        ps && qs && !(ps & qs).empty?
      end

      # Merges collected references of atoms to parent specs
      # @param [Hash] prev_refs the previous collected references
      # @return [Hash] new_refs the references which were collecected in difference
      #   operation
      # @return [Hash] the merging result where each value is list of possible values
      def merge(prev_refs, new_refs)
        new_refs.each_with_object(prev_refs.dup) do |(a, ps), result|
          result[a] ||= []
          result[a] += ps
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
