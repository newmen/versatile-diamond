require 'singleton'

class Phase < ComplexComponent
  include Singleton

  def spec(name)
    nested(spec_class.add(name))
  end

  def temperature(value)
    @temperature = value
  end
end
