require 'singleton'

class Phase < Component
  include Singleton

  def interpret(line)
    if line =~ /\A\s/ && @current_spec
      super { pass_line_to(@current_spec, line) }
    else
      @current_spec = nil if line !~ /\A\s/ && @current_spec
      super
    end
  end

  def spec(name)
    @current_spec = spec_class.add(name)
  end

  def temperature(value)
    @temperature = value
  end
end
