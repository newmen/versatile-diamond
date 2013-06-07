module VersatileDiamond

  class LateralizedEquation < Equation
    def initialize(concrete_wheres, source_specs, products_specs, name)
      super(source_specs, products_specs, name)
      @concrete_wheres = concrete_wheres
    end

    def visit(visitor)
      super do
        @concrete_wheres.each { |where| where.visit(visitor) }
      end
    end

    def wheres
      @concrete_wheres.map(&:where)
    end

  private

    def reverse_params
      [@concrete_wheres, *super]
    end
  end

end
