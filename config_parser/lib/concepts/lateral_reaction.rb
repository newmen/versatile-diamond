module VersatileDiamond
  module Concepts

    # TODO: rspec
    class LateralReaction < Reaction

      # Among super, keeps the atom map
      # @param [Array] super_args the arguments of super method
      # @param [Array] atoms_map the atom-mapping result
      def initialize(*super_args, theres)
        super(*super_args)
        @theres = theres
      end

      # def wheres
      #   @theres.map(&:where)
      # end

      # def same?(other)
      #   if self.class == other.class
      #     compare_with_other(other) { |cw1, cw2| cw1.same?(cw2) }
      #   else
      #     false
      #   end
      # end

      # def organize_dependencies(lateral_equations)
      #   lateral_equations.each do |equation|
      #     next if equation == self
      #     next unless compare_with_other(equation) do |self_cw, other_cw|
      #       other_cw.cover?(self_cw)
      #     end

      #     dependent_from << equation
      #   end
      # end

    protected

      # attr_reader :theres

    private

      def reverse_params
        [*super, @theres] # TODO: rebind to another atoms
      end

      # def accept_self(visitor)
      #   @theres.each { |where| where.visit(visitor) }
      #   visitor.accept_lateral_equation(self)
      # end

      # def compare_with_other(other, &block)
      #   # calling a .same? method from superclass
      #   self.class.superclass.instance_method(:same?).bind(self).call(other) &&
      #     lists_are_identical?(@theres, other.theres, &block)
      # end
    end

  end
end
