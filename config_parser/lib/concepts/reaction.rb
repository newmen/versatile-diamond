module VersatileDiamond
  module Concepts

    # Also contained positions between the reactants
    class Reaction < UbiquitousReaction

      # Among super, keeps the atom map
      # @param [Array] super_args the arguments of super method
      # @param [Mcs::MappingResult] mapping the atom-mapping result
      def initialize(*super_args, mapping)
        super(*super_args)
        @mapping = mapping
      end

      # Also store positions for reverse reaction
      # @return [Reaction] reversed reaction
      # @override
      def reverse
        super { |r| r.positions = @positions } # TODO: need to reverse possitions too?
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
        @mapping.swap_source(from, to)
      end

      # Provides positions between atoms of reactntant
      # @return [Array] the positions array
      def positions
        @positions ||= []
      end

      # Also compares positions in both reactions
      # @param [UbiquitousReaction] see at #super same argument
      # @override
      def same?(other)
        is_same_positions =
          lists_are_identical?(positions, other.positions) do |pos1, pos2|
            pos1.last == pos2.last &&
              ((pos1[0] == pos2[0] && pos1[1] == pos2[1]) ||
                (pos1[0] == pos2[1] && pos1[1] == pos2[0]))
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

    protected

      attr_reader :children
      attr_writer :positions

      # Gets an appropriate representation of the reaction
      # @param [Symbol] type the type of parent reaction
      def as(type)
        @type == type ? self : reverse
      end

    private

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
    end

  end
end
