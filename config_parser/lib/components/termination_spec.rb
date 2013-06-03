module VersatileDiamond

  class TerminationSpec
    def is_gas?
      false
    end

    def extendable?
      false
    end

    def visit(visitor)
      visitor.accept_termination_spec(self)
    end

    def same?(other)
      to_s == other.to_s
    end
  end

end
