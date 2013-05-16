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

  VARIABLES = %w(temperature concentration energy time).freeze

  class << self
    VARIABLES.each do |var|
      define_method("convert_#{var}") do |value, dimension|
        instance.convert(var.to_sym, value, dimension)
      end
    end

    def convert_rate(value, gases_num, dimension)
      instance.convert_rate(value, gases_num, dimension)
    end

    def convert_value(var, cases)
      define_method("convert_#{var}") do |value, dimension|
        convert_value(value, dimension, cases)
      end
    end
  end

  (VARIABLES + %w(rate)).each do |var|
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

  def convert_rate(value, gases_num, convertable_dimension)
    dimension = convertable_dimension || @rate
    syntax_error('.is_not_set') unless dimension

    if gases_num > 0 || dimension != DEFAULT_RATE
      _, dividend, _, divisor =
        dimension.gsub(/\(|\)/, '|').gsub(/\s/, '').scan(/\A(\|)?([^\/]+)\1?\/(\|)?(.+?)\3?\Z/).first

      dividends = dividend.split('*').flat_map do |v|
        if v =~ /\A(?<units>.*?(?<symbol>m|l))(?<degree>\d+)?\Z/
          units, symbol, degree = $~[:units], $~[:symbol], $~[:degree] && $~[:degree].to_i
          if symbol == 'm' && degree % 3 == 0
            next ["#{units}3"] * (degree / 3)
          elsif symbol == 'l' && units == symbol && degree
            next ['l'] * degree
          end
        end
        v
      end
      divisors = divisor.split('*').flat_map do |v|
        if v =~ /\A(?<units>.*?)(?<degree>\d+)?\Z/
          units, degree = $~[:units], $~[:degree] && $~[:degree].to_i
          next [units] * degree if degree
        end
        v
      end

      vol = { 'mm3' => 1e3, 'cm3' => 1, 'dm3' => 1e-3, 'l' => 1e-3, 'm3' => 1e-6 }
      aos = { 'mol' => 1, 'kmol' => 1e3 }
      coef = 1
      reduct = -> part, d, c { (i = part.index(d)) && part.delete_at(i) && (coef *= c) }
      gases_num.times do
        vol.any? { |d, c| reduct[dividends, d, c] } || syntax_error('.undefined_value')
        aos.any? { |d, c| reduct[divisors, d, c] } || syntax_error('.undefined_value')
      end

      dimension = ''
      dimension << (dividends.empty? ? '1' : dividends.join('*'))
      unless divisors.empty?
        divisor = divisors.join('*')
        divisor = "(#{divisor})" if divisors.size > 1
        dimension << "/#{divisor}"
      end
      dimension = '' if dimension == '1'

      syntax_error('.undefined_value') if dimension != DEFAULT_RATE.gsub(/\s/, '')
      value * coef
    else
      value
    end
  end

private

  convert_value(:temperature, {
    # 'K' => -> v { v },
    'C' => -> v { v + 273.15 },
    'F' => -> v { (v + 459.67) / 1.8 }
  })

  convert_value(:concentration, {
    /\Amol\s*\/\s*mm3\Z/ => -> v { v * 1e3 },
    # /\Amol\s*\/\s*cm3\Z/ => -> v { v },
    /\Amol\s*\/\s*(:?dm3|l)\Z/ => -> v { v * 1e-3 },
    /\Amol\s*\/\s*m3\Z/ => -> v { v * 1e-6 },
    /\Akmol\s*\/\s*mm3\Z/ => -> v { v * 1e6 },
    /\Akmol\s*\/\s*cm3\Z/ => -> v { v * 1e3 },
    /\Akmol\s*\/\s*(:?dm3|l)\Z/ => -> v { v },
    /\Akmol\s*\/\s*m3\Z/ => -> v { v * 1e-3 }
  })

  convert_value(:energy, {
    # /kJ\s*\/\s*mol\Z/ => -> v { v },
    /kJ\s*\/\s*kmol\Z/ => -> v { v * 1e3 },
    /J\s*\/\s*mol\Z/ => -> v { v * 1e-3 },
    /kcal\s*\/\s*mol\Z/ => -> v { v * 4.184 },
    /kcal\s*\/\s*kmol\Z/ => -> v { v * 4.184e3 },
    /cal\s*\/\s*mol\Z/ => -> v { v * 4.184e-3 }
  })

  convert_value(:time, {
    /\As(?:ec)?\Z/ => -> v { v },
    /\Am(?:in)?s?\Z/ => -> v { v * 60 },
    /\Ah(?:our)?s?\Z/ => -> v { v * 3600 }
  })

  def convert_value(value, dimension, cases)
    _, func = cases.select { |matcher, _| matcher === dimension }.to_a.first
    func ? func[value] : syntax_error('.undefined_value')
  end
end
