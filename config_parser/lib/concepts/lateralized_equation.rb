module VersatileDiamond

  module Concepts

    class LateralizedEquation < Interpreter::Equation
      def initialize(concrete_wheres, name, source_specs, products_specs, atoms_map)
        super(name, source_specs, products_specs, atoms_map)
        @concrete_wheres = concrete_wheres
      end

      def wheres
        @concrete_wheres.map(&:where)
      end

      def same?(other)
        if self.class == other.class
          compare_with_other(other) { |cw1, cw2| cw1.same?(cw2) }
        else
          false
        end
      end

      def organize_dependencies(lateral_equations)
        lateral_equations.each do |equation|
          next if equation == self
          next unless compare_with_other(equation) do |self_cw, other_cw|
            other_cw.cover?(self_cw)
          end

          dependent_from << equation
        end
      end

    protected

      attr_reader :concrete_wheres

    private

      def reverse_params
        [@concrete_wheres, *super]
      end

      def accept_self(visitor)
        @concrete_wheres.each { |where| where.visit(visitor) }
        visitor.accept_lateral_equation(self)
      end

      def compare_with_other(other, &block)
        # calling a .same? method from superclass
        self.class.superclass.instance_method(:same?).bind(self).call(other) &&
          lists_are_identical?(@concrete_wheres, other.concrete_wheres, &block)
      end
    end

  end

end
