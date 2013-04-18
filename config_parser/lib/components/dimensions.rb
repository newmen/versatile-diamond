require 'singleton'

class Dimensions < Component
  include Singleton

  # These values are using into calculation program on C++ by default
  # On these values bases convert_value methods ​​in this class
  DEFAULT_TEMPERATURE = 'K'.freeze
  DEFAULT_CONCENTRATION = 'mol/cm3'.freeze
  DEFAULT_ENERGY = 'kJ/mol'.freeze
  DEFAULT_RATE = '1/s'.freeze
  DEFAULT_TIME = 's'.freeze

  VARIABLES = %w(temperature concentration energy rate time).freeze

  class << self
    VARIABLES.each do |var|
      define_method("convert_#{var}") do |value, dimension|
        instance.convert(var.to_sym, value, dimension)
      end
    end

    def convert_value(var, cases)
      define_method("convert_#{var}") do |value, dimension|
        convert_value(value, dimension, cases)
      end
    end
  end

  VARIABLES.each do |var|
    define_method(var) do |value|
      instance_variable_set("@#{var}".to_sym, value.strip)
    end
  end

  def convert(var, value, convertable_dimension)
    convertable_dimension && convertable_dimension.strip!

    current_dimension = instance_variable_get("@#{var}".to_sym)
    syntax_error('.is_not_set') unless current_dimension || convertable_dimension
    default_dimension = self.class.const_get("DEFAULT_#{var.to_s.upcase}")
    if (!convertable_dimension && current_dimension == default_dimension) || convertable_dimension == default_dimension
      return value
    end

    send("convert_#{var}", value, convertable_dimension || current_dimension)
  end

private

  convert_value(:temperature, {
    # 'K' => -> v { v },
    'C' => -> v { v + 273.15 },
    'F' => -> v { (v + 459.67) / 1.8 }
  })

  convert_value(:concentration, {
    # /\Amol\s*\/\s*cm3\Z/ => -> v { v },
    /\Amol\s*\/\s*(:?dm3|l)\Z/ => -> v { v * 1e-3 },
    /\Amol\s*\/\s*m3\Z/ => -> v { v * 1e-6 },
    /\Akmol\s*\/\s*cm3\Z/ => -> v { v * 1e3 },
    /\Akmol\s*\/\s*(:?dm3|l)\Z/ => -> v { v },
    /\Akmol\s*\/\s*m3\Z/ => -> v { v * 1e-3 }
  })

  convert_value(:energy, {
    # /kJ\s*\/\s*mol\Z/ => -> v { v },
    /kJ\s*\/\s*kmol\Z/ => -> v { v * 1e3 },
    /J\s*\/\s*mol\Z/ => -> v { v * 1e-3 },
    /kcal\s*\/\s*mol\Z/ => -> v { v * 4.2 },
    /kcal\s*\/\s*kmol\Z/ => -> v { v * 4.2e3 },
    /cal\s*\/\s*mol\Z/ => -> v { v * 4.2e-3 }
  })

  convert_value(:rate, {
    # /\A1\s*\/\s*s/ => -> v { v }
  })

  convert_value(:time, {
    /\As(?:ec)?\Z/ => -> v { v },
    /\Am(?:in)?s?\Z/ => -> v { v * 60 },
    /\Ah(?:our)?s?\Z/ => -> v { v * 3600 }
  })

  def convert_value(value, dimension, cases)
    _, func = cases.select { |matcher, _| matcher === dimension }.to_a.first
    func ? func.call(value) : syntax_error('.undefined_value')
  end
end
