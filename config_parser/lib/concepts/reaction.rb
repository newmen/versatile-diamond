module VersatileDiamond
  module Concepts

    # Also contained positions between the reactants
    class Reaction < UbiquitousReaction

      # Among super, keeps the atom map
      # @param [Array] super_args the arguments of super method
      # @param [Array] atoms_map the atom-mapping result
      def initialize(*super_args, atoms_map)
        super(*super_args)
        @atoms_map = atoms_map
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

      # Provides positions between atoms of reactntant
      # @return [Array] the positions array
      def positions
        @positions ||= []
      end

      # def same?(other)
      #   is_same_positions = (!@positions && !other.positions) ||
      #     (@positions && other.positions &&
      #       lists_are_identical?(@positions, other.positions) do |pos1, pos2|
      #         pos1.last == pos2.last &&
      #           ((pos1[0] == pos2[0] && pos1[1] == pos2[1]) ||
      #             (pos1[0] == pos2[1] && pos1[1] == pos2[0]))
      #       end)

      #   is_same_positions && super
      # end

      # def simple_source
      #   @simple_source ||= @source.select do |specific_spec|
      #     specific_spec.simple?
      #   end
      # end

      # def complex_source
      #   @complex_source ||= @source - simple_source
      # end

      # def organize_dependencies(lateral_equations)
      #   applicants = []
      #   lateral_equations.each do |equation|
      #     applicants << equation if same?(equation)
      #   end

      #   return if applicants.empty?

      #   loop do
      #     inc = applicants.select do |equation|
      #       applicants.find do |uneq|
      #         equation != uneq && equation.dependent_from.include?(uneq)
      #       end
      #     end
      #     break if inc.empty?
      #     applicants = inc
      #   end

      #   applicants.each { |equation| dependent_from << equation }
      # end

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
        childs = @children || reverse.children
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
        reversed_atom_map = @atoms_map.map do |specs, indexes|
          [specs.reverse, indexes.map { |pair| pair.reverse }]
        end
        [*super, reversed_atom_map]
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

        atoms_map = @atoms_map.map do |(source, product), indexes|
          [[mirrors[source], mirrors[product]], indexes]
        end

        mirrors.each(&block)

        [@type, "#{@name} #{name_tail}", source_dup, products_dup, atoms_map]
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

      # def accept_self(visitor)
      #   visitor.accept_real_equation(self)
      # end

      # def analyze_and_visit_source_specs(visitor)
      #   @source.each do |spec|
      #     spec.look_around(@atoms_map)
      #     spec.visit(visitor)
      #   end
      # end
    end

  end
end
