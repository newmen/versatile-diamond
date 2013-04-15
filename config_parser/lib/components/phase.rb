class Phase < Component
  def interpret(line)
    super { pass_line_to(@last_spec, line) }
  end

  def spec(name)
    @last_spec = spec_class.add(name)
  end
end
