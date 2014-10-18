module VersatileDiamond
  using Patches::RichArray

  module Organizers

    # Contain some spec and set of dependent specs
    class DependentBaseSpec < DependentWrappedSpec
      include MultiParentsSpec

      def_delegators :@spec, :size

      # Initializes dependent base spec
      # @param [Array] args the arguments of DependentWrappedSpec constructor
      def initialize(*args)
        super(*args)
        @_parents_are_replaced = false
        @parents = nil # using by MultiParentsSpec module
      end

      # Gets sorted parents of target specie
      # @return [Array] the sorted array of parent seqeucnes
      # @override
      def parents
        original_parents = super

        return original_parents if @_parents_are_replaced
        @_parents_are_replaced = true

        return original_parents if original_parents.not_uniq.empty?

        shared_atoms = links.keys
        reducing_rest = self
        @parents = original_parents.map do |parent|
          is_uniq_parent = original_parents.count(parent) == 1

          unless is_uniq_parent
            self_atoms = reducing_rest.mirror_to(parent).map(&:first)
          end
          reducing_rest -= parent

          is_uniq_parent ? parent : ProxyParentSpec.new(parent, self, self_atoms)
        end
      end

      # Checks that other spec has same atoms and links between them
      # @param [DependentBaseSpec] other the comparable spec
      # @return [Boolean] same or not
      def same?(other)
        other.is_a?(DependentSpec) ? spec.same?(other.spec) : other.same?(self)
      end

      # Is unused spec or not
      # @return [Boolean] is unused or not
      def unused?
        children.empty? && !reactant?
      end

      # Is excess spec or not
      # @return [Boolean] is excess spec or not
      def excess?
        !source? && !complex? &&
          children.size == 1 && children.first.specific? && !reactant?
      end

      # Excludes current spec. Instead of the current spec replaces the parent to the
      # child and vice versa. Should have only one parent and only one child.
      # @raise [RuntimeError] if spec is not excess and not unused
      def exclude
        raise 'Unexcess spec could be exclude or unused' unless excess? || unused?

        parents.uniq.each { |parent| parent.remove_child(self) }

        return if children.empty?
        if complex?
          raise 'Excluding specie has more that one parent and many children'
        end

        parent = parents.first
        children.each do |child|
          parent ? child.replace_parent(parent) : child.remove_parent(self)
        end
      end

      # Organize dependencies from another specs by dynamic table
      # @param [BaseSpeciesTable] table the dynamic table of species dependencies
      def organize_dependencies!(table)
        cell = table.best(self)
        if cell # if not only one specie in table
          store_rest(cell.residual) unless self == cell.residual
          cell.specs.each { |spec| store_parent(spec) }
        end
      end

    private

      # Is current spec reactant or not
      # @return [Boolean] is reactant or not
      def reactant?
        !(reactions.empty? && theres.empty?)
      end
    end

  end
end
