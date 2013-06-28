module VersatileDiamond

  class LateralizedEquation < Equation
    def initialize(concrete_wheres, name, source_specs, products_specs, atoms_map)
      super(name, source_specs, products_specs, atoms_map)
      @concrete_wheres = concrete_wheres
    end

    def wheres
      @concrete_wheres.map(&:where)
    end

    def same?(other)
      if self.class == other.class
        super && lists_are_identical?(
          @concrete_wheres, other.concrete_wheres) do |cw1, cw2|
            cw1.same?(cw2)
          end
      else
        false
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
  end

end
