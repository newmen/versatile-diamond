module VersatileDiamond
  module Concepts

    # Also contained positions between the reactants
    class Reaction < UbiquitousReaction
      include Linker
      include SurfaceLinker

      attr_reader :links

      # Among super, keeps the atom map
      # @param [Array] super_args the arguments of super method
      # @param [Mcs::MappingResult] mapping the atom-mapping result
      def initialize(*super_args, mapping)
        super(*super_args)
        @mapping = mapping
        @links = {} # contain positions between atoms of different reactants

        @mapping.find_positions_for(self)
      end

      # Reduce all positions from links structure
      # @return [Array] the array of position relations
      def positions
        links.reduce([]) do |acc, (atom, list)|
          acc + list.reduce([]) do |l, (other_atom, position)|
            l << [atom, other_atom, position]
          end
        end
      end

      # Store position relation between first and second atoms
      # @param [Array] first the array with first spec and atom
      # @param [Array] second the array with second spec and atom
      # @param [Position] position the position relation between atoms of both
      #   species
      # @raise [Lattices::Base::UndefinedRelation] if used relation instance is
      #   wrong for current lattice
      # @raise [Position::Duplicate] if same position already exist
      # @raise [Position::UnspecifiedAtoms] if not all atoms belongs to crystal
      #   lattice
      def position_between(first, second, position)
        if @mapping.reaction_type == :dissociation
          raise "Cannot link atoms of single structure"
        end

        link_together(first, second, position)
        return if @mapping.reaction_type == :association

        first = @mapping.other_side(*first)
        second = @mapping.other_side(*second)
        reverse.link_together(first, second, position)
      end

      # Duplicates current instance with each source and product specs and
      # store it to children array
      #
      # @param [String] name_tail the tail of reaction name
      # @yield [Symbol, Hash] do for each specs mirror of source and products
      # @return [Reaction] the duplicated reaction with changed name
      def duplicate(name_tail, &block)
        duplication = self.class.new(*duplicate_params(name_tail, &block))
        setup_duplication(duplication)
      end

      # Duplicates current instance and creates lateral reaction instance with
      # setted theres
      #
      # @param [String] name_tail see at #duplicate same argument
      # @param [Array] theres the array of there objects
      # @yield see at #duplicate same argument
      def lateral_duplicate(name_tail, theres, &block)
        duplication = LateralReaction.new(
          *duplicate_params(name_tail, &block), theres)
        setup_duplication(duplication)
      end

      # Also changes atom mapping result
      # @param [TerminationSpec | SpecificSpec] from which spec will be deleted
      # @param [TerminationSpec | SpecificSpec] to which spec will be added
      # @override
      def swap_source(from, to)
        super

        each_spec_atom do |spec_atom|
          if spec_atom[0] == from
            spec_atom[1] = to.atom(spec_atom[0].keyname(spec_atom[1]))
            spec_atom[0] = to
          end
        end

        @mapping.swap_source(from, to)
      end

      # Swaps used specific spec atom to new atom (used only when atom was
      # changed for some specific spec and not chaned for current reaction)
      #
      # @param [SpecificSpec] spec the specific spec the atom of which will be
      #   swapped
      # @param [Atom] from the used atom
      # @param [Atom] to the new atom
      def swap_atom(spec, from, to)
        each_spec_atom do |spec_atom|
          spec_atom[1] = to if spec_atom[0] == spec && spec_atom[1] == from
        end

        @mapping.swap_atom(spec, from, to)
      end

      # Also compares positions in both reactions
      # @param [UbiquitousReaction] see at #super same argument
      # @override
      def same?(other)
        is_same_positions =
          lists_are_identical?(positions, other.positions) do |pos1, pos2|
            pos1.last == pos2.last && # compares position relation instances
              ((pos1[0][0].same?(pos2[0][0]) && pos1[0][1].same?(pos2[0][1]) &&
                pos1[1][0].same?(pos2[1][0]) && pos1[1][1].same?(pos2[1][1])) ||
                (pos1[0][0].same?(pos2[0][1]) && pos1[0][1].same?(pos2[0][0]) &&
                 pos1[1][0].same?(pos2[1][1]) && pos1[1][1].same?(pos2[1][0])))
          end

        is_same_positions && super
      end

      # Selects complex source specs and them changed atom
      # @return [Array] cached array of complex source specs
      def complex_source_covered_by?(termination_spec)
        spec, atom = @mapping.complex_source_spec_and_atom
        termination_spec.cover?(spec, atom)
      end

      # Organize dependencies from another lateral reactions
      # @param [Array] lateral_reactions the possible children
      # @override but another type of argument
      def organize_dependencies!(lateral_reactions)
        applicants = []
        lateral_reactions.each do |reaction|
          applicants << reaction if same?(reaction)
        end

        return if applicants.empty?

        loop do
          inc = applicants.select do |reaction|
            applicants.find do |unr|
              reaction != unr && reaction.more_complex.include?(unr)
            end
          end
          break if inc.empty?
          applicants = inc
        end

        applicants.each { |reaction| more_complex << reaction }
      end

      # Checks that all atoms belongs to lattice
      # @return [Array] atoms the array of checking atoms
      # @return [Boolean] all or not
      def all_latticed?(*atoms)
        atoms.all?(&method(:has_lattice?))
      end

    protected

      attr_reader :children
      attr_writer :positions

      # Gets an appropriate representation of the reaction
      # @param [Symbol] type the type of parent reaction
      def as(type)
        @type == type ? self : reverse
      end

      # Links together two structures by it atoms
      # @param [Array] first see at #position_between same argument
      # @param [Array] second see at #position_between same argument
      # @param [Position] position see at #position_between same argument
      # @override
      def link_together(first, second, position)
        unless all_latticed?(first.last, second.last)
          raise Position::UnspecifiedAtoms
        end

        @links[first] ||= []
        @links[second] ||= []

        super
      end

    private

      # Gets opposite relation between first and second atoms for passed
      # relation instance
      #
      # @param [Array] first see at #position_between same argument
      # @param [Array] second see at #position_between same argument
      # @param [Position] position see at #position_between same argument
      # @raise [Lattices::Base::UndefinedRelation] when passed relation is
      #   undefined
      # @return [Position] the opposite position relation
      def opposit_relation(first, second, relation)
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
        childs = children || reverse.children
        if childs
          childs.each do |reaction|
            reaction.as(@type).send(:"#{attribute}=", value)
          end
        else
          super
        end
      end

      # Reverse params for creating reverse reaction with reversing of atom
      # mapping result
      #
      # @return [Array] reversed parameters for creating reverse reaction
      # @override
      def reverse_params
        [*super, @mapping.reverse]
      end

      # Duplicates internal properties of reaction such as specs and atom
      # mapping result
      #
      # @param [String] name_tail see at #duplicate same argument
      # @yield [Symbol, Hash] see at #duplicate same argument
      # @return [Array] the array of duplicated properties
      def duplicate_params(name_tail, &block)
        mirrors = {}
        dup_and_save = -> type, specs do
          mirror = mirrors[type] = {}
          specs.map do |spec|
            spec_dup = spec.dup
            mirror[spec] = spec_dup
            spec_dup
          end
        end

        source_dup = dup_and_save[:source, @source]
        products_dup = dup_and_save[:products, @products]

        mirrors.each(&block)

        mapping = @mapping.duplicate(mirrors)
        [@type, "#{@name} #{name_tail}", source_dup, products_dup, mapping]
      end

      # Setups duplicated reaction
      # @param [Reaction] duplication the setuping duplicated reaction
      # @return [Reaction] setuped duplicated reaction
      def setup_duplication(duplication)
        duplication.positions = @positions.dup if @positions

        @children ||= []
        @children << duplication # TODO: rspec it

        duplication
      end

      # Do something in links container by passed block
      # @yield [Array] the array where first item is spec and second item is
      #   atom of it spec
      def each_spec_atom(&block)
        @links.each do |spec_atom1, references|
          block[spec_atom1]
          references.each { |spec_atom2, _| block[spec_atom2] }
        end
      end
    end

  end
end
