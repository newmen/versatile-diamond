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
end
