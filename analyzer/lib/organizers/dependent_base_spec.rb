module VersatileDiamond
  using Patches::RichArray

  module Organizers

    # Contain some spec and set of dependent specs
    class DependentBaseSpec < DependentWrappedSpec

      # @return [Array]
      def specific_atoms
        []
      end

      # Checks that spec is excess
      # @return [Boolean] is excess spec or not
      # @override
      def excess?
        !source? && !complex? &&
          children.one? && children.first.specific? && !reactant?
      end

      # Excludes current spec. Instead of the current spec replaces the parent to the
      # child and vice versa. Should have only one parent and only one child.
      # @raise [RuntimeError] if spec is not excess and not unused
      def exclude
        raise 'Excluding spec should be excess or unused' unless excess? || unused?

        parents.map(&:original).uniq.each { |parent| parent.remove_child(self) }

        return if children.empty?

        parent = parents.first.original
        children.each do |child|
          parent ? child.replace_base_spec(parent) : child.remove_parent(self)
        end
      end

      # Organize dependencies from another specs by dynamic table
      # @param [BaseSpeciesTable] table the dynamic table of species dependencies
      def organize_dependencies!(table)
        rest = table.best(self)
        store_rest(rest) unless rest == self
      end

    private

      # Provides the lowest level of comparing two minuend instances
      # @param [MinuendSpec] other comparing instance
      # @return [Integer] the result of comparation
      def comparing_core(other)
        order(self, other, :external_bonds) do
          super(other)
        end
      end
    end

  end
end
