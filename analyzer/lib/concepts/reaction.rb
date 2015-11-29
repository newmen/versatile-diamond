module VersatileDiamond
  using Patches::RichArray

  module Concepts

    # Also contained positions between the reactants
    class Reaction < UbiquitousReaction
      include Modules::GraphDupper
      include Modules::SpecAtomSwapper
      include Linker
      include SurfaceLinker
      include PositionsComparer
      extend Forwardable

      # type of reaction could be only for not ubiquitous reaction
      attr_reader :type, :links, :children

      # Among super, keeps the atom map
      # @param [Array] super_args the arguments of super method
      # @param [Mcs::MappingResult] mapping the atom-mapping result
      def initialize(*super_args, mapping)
        super(*super_args)
        @mapping = mapping
        @links = {} # contain positions between atoms of different reactants

        @parent = nil
        @children = []

        @mapping.find_positions_for(self)
      end

      def_delegator :mapping, :complex_source_spec_and_atom

      # Gets an appropriate representation of the reaction
      # @param [Symbol] type the type of parent reaction
      def as(type)
        @type == type ? self : reverse
      end

      # Store position relation between first and second atoms
      # @param [Array] first the array with first spec and atom
      # @param [Array] second the array with second spec and atom
      # @param [Position] position the position relation between atoms of both
      #   species
      # @option [Boolean] :check_possible is flag that another positions should be
      #   checked
      # @raise [RuntimeError] if linking atoms belongs to one spec
      # @raise [Lattices::Base::UndefinedRelation] if used relation instance is
      #   wrong for current lattice
      # @raise [Position::Duplicate] if same position already exist
      # @raise [Position::UnspecifiedAtoms] if not all atoms belongs to crystal
      #   lattice
      def position_between(first, second, position, check_possible: true)
        if mapping.reaction_type == :dissociation
          raise 'Cannot link atoms of single structure'
        end

        link_together(first, second, position, check_possible: check_possible)
        return if mapping.reaction_type == :association

        first = mapping.other_side(*first)
        second = mapping.other_side(*second)
        reverse.link_together(first, second, position)
      end

      # Duplicates current instance with each source and product specs and
      # store it to children array
      #
      # @param [String] name_tail the tail of reaction name
      # @yield [Symbol, Hash] do for each specs mirror of source and products
      # @return [Reaction] the duplicated reaction with changed name
      def duplicate(name_tail, &block)
        duplicate_by(self.class, name_tail) do |mirrors|
          mirrors.each(&block)
        end
      end

      # Duplicates current instance and creates lateral reaction instance with
      # setted theres
      #
      # @param [String] name_tail see at #duplicate same argument
      # @param [Array] theres the array of there objects
      # @yield see at #duplicate same argument
      def lateral_duplicate(name_tail, theres, &block)
        theres = theres.map(&:dup) # because each there will be changed

        duplicate_by(LateralReaction, name_tail, theres) do |mirrors|
          mirrors.each(&block)

          mirror = mirrors[:source]
          # here there objects which was used for creating a duplicate, will be
          # changed by swapping target species
          theres.each do |there|
            there.target_specs.each do |spec|
              there.swap_target(spec, mirror[spec])
            end
          end
        end
      end

      # Also remember reversed children
      # @return [Reaction] the reversed reaction
      # @override
      def reverse
        return @reverse if @reverse
        result = super
        @parent.reverse.children << result if @parent && @parent.has_reverse?
        children.each { |child| result.children << child.reverse }
        result
      end

      # Also changes atom mapping result
      # @param [TerminationSpec | SpecificSpec] from which spec will be deleted
      # @param [TerminationSpec | SpecificSpec] to which spec will be added
      # @override
      def swap_source(from, to)
        super
        @links = swap_in_links(:swap, @links, from, to)
        mapping.swap_source(from, to)
      end

      # Swaps using atoms of passed spec
      # @param [Spec | SpecificSpec] spec for which the atoms will be swapped
      # @param [Atom | AtomReference| SpecificAtom] from the atom which will be swapped
      # @param [Atom | AtomReference| SpecificAtom] to the atom to which will be
      #   swapped
      def swap_atom(spec, from, to)
        swap_atom_in_positions(spec, from, to)
        mapping.swap_atom(spec, from, to)
      end

      # Applies relevant states for other side atom
      # @param [SpecificSpec] spec
      # @param [Atom | SpecificAtom] old_atom the atom which will be replaced
      # @param [SpecificAtom] new_atom the atom to which will be changed
      # @option [Boolean] :to_reverse_too applies relevant state to reverse
      #   reaction if set to true
      def apply_relevants(spec, old_atom, new_atom, to_reverse_too: true)
        is_source = source.include?(spec)

        if to_reverse_too
          os_s, os_old_a = mapping.other_side(spec, old_atom)
          mapping.apply_relevants(spec, old_atom, new_atom)
          _, os_new_a = mapping.other_side(spec, new_atom)

          if is_source
            reverse.apply_relevants(os_s, os_old_a, os_new_a, to_reverse_too: false)
          else
            apply_relevants(os_s, os_old_a, os_new_a, to_reverse_too: false)
            reverse.apply_relevants(spec, old_atom, new_atom, to_reverse_too: false)
          end
        end

        swap_atom_in_positions(spec, old_atom, new_atom) if is_source
      end

      # Gets all atoms of passed spec which used in reaction
      # @param [Spec | SpecificSpec] spec the one of reactant
      # @return [Array] the array of using atoms
      def used_atoms_of(spec)
        pos_atoms = @links.keys.select { |s, _| s == spec }.map(&:last)
        (pos_atoms + changed_atoms_of(spec)).uniq
      end

      # Also compares positions in both reactions
      # @param [UbiquitousReaction] see at #super same argument
      # @override
      def same?(other)
        super && same_positions?(other)
      end

      # Typical reaction isn't lateral
      # @return [Boolean] false
      def lateral?
        false
      end

      # Checks that all atoms belongs to lattice
      # @return [Array] atoms the array of checking atoms
      # @return [Boolean] all or not
      def all_latticed?(*atoms)
        a, b = atoms.map(&:lattice)
        a && a == b
      end

      # Gets atom changes list
      # @return [Hash] the hash of changes where keys are spec-atom of source and
      #   values are spec-atom of products
      def changes
        Hash[MappingResult.rezip(mapping.changes)]
      end

      # Gets number of changed atoms
      # @return [Integer] the number of changed atoms
      # @override
      def changes_num
        changes.size
      end

      # Reorganizes the specs of children reactions
      def reorganize_children_specs!
        children.each do |child|
          if same_specs?(child) && same_positions?(child)
            swap_by_map!(child, map_to_specs_of(child, :source))
          end
        end
      end

    protected

      attr_writer :parent, :links

      # Links together two structures by it atoms
      # @param [Array] first see at #position_between same argument
      # @param [Array] second see at #position_between same argument
      # @param [Position] position see at #position_between same argument
      # @raise [Position::UnspecifiedAtoms] if first or second atom isn't
      #   specified by lattice
      # @override
      def link_together(first, second, position, **)
        raise Position::UnspecifiedAtoms unless all_latticed?(first.last, second.last)

        @links[first] ||= []
        @links[second] ||= []

        super
      end

    private

      attr_reader :mapping

      # Makes the mirror of current specs to specs of child
      # @param [Reaction] child to which specs the map will builded
      # @param [Symbol] method for get a list of specs
      # @return [Array] the map of specs
      def map_to_specs_of(child, method)
        child_specs = child.public_send(method).dup
        public_send(method).reduce([]) do |acc, self_spec|
          child_spec = child_specs.find { |s| self_spec.same?(s) }
          acc << [self_spec, child_specs.delete_one(child_spec)]
        end
      end

      # Swaps specs of child reaction by passed map
      # @param [Reaction] child which specs will be swapped
      # @param [Hash] specs_map which will used for get correspond specs of current
      #   reaction
      def swap_by_map!(child, specs_map)
        specs_map.each do |self_spec, child_spec|
          child.swap_source(child_spec, self_spec)
        end
      end

      # Gets opposite relation between first and second atoms for passed
      # relation instance
      #
      # @param [Array] first see at #position_between same argument
      # @param [Array] second see at #position_between same argument
      # @param [Position] position see at #position_between same argument
      # @raise [Lattices::Base::UndefinedRelation] when passed relation is
      #   undefined
      # @return [Position] the opposite position relation
      def opposite_relation(first, second, relation)
        _, first_atom = first
        _, second_atom = second
        first_atom.lattice.opposite_relation(second_atom.lattice, relation)
      end

      # Updates attribute for current instance, or setup each child if they
      # exists
      #
      # @param [Symbol] attribute see at #super same argument
      # @param [Float] value see at #super same argument
      # @override
      def update_attribute(attribute, value)
        if children.empty?
          super
        else
          children.each do |child|
            child.send(:"#{attribute}=", value)
          end
        end
      end

      # Gets changed atoms of passed spec
      # @param [Spec | SpecificSpec] spec the one of reactant
      # @return [Array] the array of using atoms
      def changed_atoms_of(spec)
        mapping.used_atoms_of(spec)
      end

      # Reverse params for creating reverse reaction with reversing of atom
      # mapping result
      #
      # @return [Array] reversed parameters for creating reverse reaction
      # @override
      def reverse_params
        [*super, mapping.reverse]
      end

      # Duplicates current instance
      # @param [Class] klass the class instance of which will be returned
      # @param [String] name_tail see at #duplicate same argument
      # @param [Array] add_params the additional parameters of duplication
      # @yield [Symbol, Hash] does anything with obtained mirrors
      # @return [Reaction] duplicate of current reaction
      def duplicate_by(klass, name_tail, *add_params, &block)
        mirrors, *params = duplicate_params(name_tail)
        block[mirrors]

        duplication = klass.new(*(params + add_params))
        setup_duplication(duplication, mirrors)
      end

      # Duplicates internal properties of reaction such as specs and atom
      # mapping result
      #
      # @param [String] name_tail see at #duplicate same argument
      # @return [Array] the array of duplicated properties
      def duplicate_params(name_tail)
        mirrors = {}
        dup_and_save = -> type, specs do
          mirrors[type] = {}
          specs.map { |spec| mirrors[type][spec] = spec.dup }
        end

        source_dup = dup_and_save[:source, @source]
        products_dup = dup_and_save[:products, @products]

        mapping = @mapping.duplicate(mirrors)
        [mirrors, @type, "#{@name} #{name_tail}", source_dup, products_dup, mapping]
      end

      # Setups duplicated reaction
      # @param [Reaction] duplication the setuping duplicated reaction
      # @param [Hash] mirrors the mirrors of currents specs to specs in
      #   duplication
      # @return [Reaction] setuped duplicated reaction
      def setup_duplication(duplication, mirrors)
        old_to_dup = mirrors.values.reduce(&:merge)
        duplication.links = dup_graph(@links) do |old_spec, old_atom|
          dup_spec = old_to_dup[old_spec]
          [dup_spec, dup_spec.atom(old_spec.keyname(old_atom))]
        end

        duplication.parent = self
        @children << duplication

        duplication
      end

      # Swaps used specific spec atom to new atom (used only when atom was
      # changed for some specific spec and not chaned for current reaction)
      #
      # @param [SpecificSpec] spec the specific spec the atom of which will be swapped
      # @param [Atom] from the used atom
      # @param [Atom] to the new atom
      def swap_atom_in_positions(spec, from, to)
        return if from == to
        @links = swap_in_links(:swap_only_atoms, @links, spec, from, to)
      end
    end

  end
end
