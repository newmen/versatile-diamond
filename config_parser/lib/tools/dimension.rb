module VersatileDiamond
  module Tools

    # Converts the passing values in concrete dimension to self
    #   dimension values
    class Dimension

      # Universal gas constant
      R = 8.3144621 # J/(mol * K)

      # These values are using into calculation program on C++ by default
      # On these values bases convert_value methods ​​in this class
      DEFAULT_TEMPERATURE = 'K'.freeze
      DEFAULT_CONCENTRATION = 'mol/cm3'.freeze
      DEFAULT_ENERGY = 'J/mol'.freeze
      DEFAULT_RATE = '1/s'.freeze
      DEFAULT_TIME = 's'.freeze

      # Varibales which can be converted
      VARIABLES = %w(concentration energy rate temperature time).freeze

      class << self
        include Modules::SyntaxChecker

        VARIABLES.each do |var|
          # Defines setting method adjusts dimension of which to produce
          #   convertion by default
          # @param [String] dimension
          define_method("#{var}_dimension") do |dimension|
            # TODO: dimension value need to check by regex
            instance_variable_set("@#{var}".to_sym, dimension)
          end
        end

        (VARIABLES - %w(rate)).each do |var|
          # Defines public convert method for all vars except rate. Each
          #   method converts variable value from passed dimension to
          #   self value.
          #
          # @param [Float] value which will be recalculated
          # @param [String] dimension from which will be convertation, if not
          #   passed then defaul dimension will be used
          # @raise [Errors::SyntaxError] if cannot be converted from
          #   passed dimension, or dimension is not passed and default
          #   is not setted
          # @return [Float] converted value
          define_method("convert_#{var}") do |value, dimension = nil|
            convert(var.to_sym, value, dimension)
          end
        end

        # Converts the rate and checks dimension in accordance with species of
        #   gas phase
        #
        # @param [Float] value see as #convert_{var}
        # @param [Integer] gases_num the number of gases involved in reaction
        # @param [String] dimension see as #convert_{var}
        # @raise [Errors::SyntaxError] see as #convert_{var}
        # @return [Float] converted rate value
        def convert_rate(value, gases_num, dimension = nil)
          dimension ||= @rate
          syntax_error('.is_not_set') unless dimension

          if gases_num > 0 || dimension != DEFAULT_RATE
            _, dividend, _, divisor =
              dimension.gsub(/\(|\)/, '|').gsub(/\s/, '').
                scan(/\A(\|)?([^\/]+)\1?\/(\|)?(.+?)\3?\Z/).first

            syntax_error('.undefined_value') unless dividend && divisor

            dividends = dividend.split('*').flat_map do |v|
              m = /\A(?<units>.*?(?<symbol>m|l))(?<degree>\d+)?\Z/.match(v)
              if m
                units = m[:units]
                symbol = m[:symbol]
                degree = m[:degree] && m[:degree].to_i

                if symbol == 'm' && degree % 3 == 0
                  next ["#{units}3"] * (degree / 3)
                elsif symbol == 'l' && units == symbol && degree
                  next ['l'] * degree
                end
              end
              v
            end
            divisors = divisor.split('*').flat_map do |v|
              m = /\A(?<units>.*?)(?<degree>\d+)?\Z/.match(v)
              if m
                units, degree = m[:units], m[:degree] && m[:degree].to_i
                next [units] * degree if degree
              end
              v
            end

            aos = { 'mol' => 1, 'kmol' => 1e3 }
            vol = {
              'mm3' => 1e3,
              'cm3' => 1,
              'dm3' => 1e-3,
              'l' => 1e-3,
              'm3' => 1e-6
            }

            coef = 1
            reduct = -> part, d, c do
              (i = part.index(d)) && part.delete_at(i) && (coef *= c)
            end

            gases_num.times do
              aos.any? { |d, c| reduct[divisors, d, c] } ||
                syntax_error('.undefined_value')

              vol.any? { |d, c| reduct[dividends, d, c] } ||
                syntax_error('.undefined_value')
            end

            dimension = ''
            dimension << (dividends.empty? ? '1' : dividends.join('*'))
            unless divisors.empty?
              divisor = divisors.join('*')
              divisor = "(#{divisor})" if divisors.size > 1
              dimension << "/#{divisor}"
            end
            dimension = '' if dimension == '1'

            if dimension != DEFAULT_RATE.gsub(/\s/, '')
              syntax_error('.undefined_value')
            end

            value * coef
          else
            value
          end
        end

      private

        # Converts variable value to setuped dimension
        # @param [Symbol] var the convertable variable
        # @param [Float] value the convertable value
        # @param [String] convertable_dimension the dimension to that will be
        #   converting
        # @raise [Errors::SyntaxError] if value cannot be converted
        # @return [Float] converted value
        def convert(var, value, convertable_dimension = nil)
          convertable_dimension && convertable_dimension.strip!

          current_dimension = instance_variable_get("@#{var}".to_sym)
          unless current_dimension || convertable_dimension
            syntax_error('.is_not_set')
          end

          default_dimension = eval("DEFAULT_#{var.to_s.upcase}")
          if (!convertable_dimension &&
              current_dimension == default_dimension) ||
            convertable_dimension == default_dimension

            return value
          end

          send("convert_#{var}_laws", value,
            convertable_dimension || current_dimension)
        end

        class << self
        private
          # Defines internal static convert method
          # @param [Symbol] var converting variable name
          # @param [Hash] cases is the hash with matching regex as keys and
          #   converting lambdas as values
          def define_convert(var, cases)
            define_method("convert_#{var}_laws") do |value, dimension|
              convert_value(value, dimension, cases) # described at the end
            end
          end
        end

        # Finds dimension converting lambda from passed cases
        # @param [Float] value the convertable value
        # @param [String] dimension the dimension from that will be converting
        # @param [Hash] cases the hash that contain regex as keys and lamdas as
        #   values
        # @raise [Errors::SyntaxError] if value cannot be converted
        # @return [Float] converted value
        def convert_value(value, dimension, cases)
          _, func = cases.find { |matcher, _| matcher === dimension }
          func ? func[value] : syntax_error('.undefined_value')
        end

        define_convert(:temperature, {
          'K' => -> v { v },
          'C' => -> v { v + 273.15 },
          'F' => -> v { (v + 459.67) / 1.8 }
        })

        define_convert(:concentration, {
          /\Amol\s*\/\s*mm3\Z/ => -> v { v * 1e3 },
          /\Amol\s*\/\s*cm3\Z/ => -> v { v },
          /\Amol\s*\/\s*(:?dm3|l)\Z/ => -> v { v * 1e-3 },
          /\Amol\s*\/\s*m3\Z/ => -> v { v * 1e-6 },
          /\Akmol\s*\/\s*mm3\Z/ => -> v { v * 1e6 },
          /\Akmol\s*\/\s*cm3\Z/ => -> v { v * 1e3 },
          /\Akmol\s*\/\s*(:?dm3|l)\Z/ => -> v { v },
          /\Akmol\s*\/\s*m3\Z/ => -> v { v * 1e-3 }
        })

        define_convert(:energy, {
          /\AJ\s*\/\s*mol\Z/ => -> v { v },
          /\AkJ\s*\/\s*mol\Z/ => -> v { v * 1e3 },
          /\AkJ\s*\/\s*kmol\Z/ => -> v { v },
          /\Akcal\s*\/\s*mol\Z/ => -> v { v * 4184 },
          /\Akcal\s*\/\s*kmol\Z/ => -> v { v * 4.184 },
          /\Acal\s*\/\s*mol\Z/ => -> v { v * 4.184 }
        })

        define_convert(:time, {
          /\As(?:ec)?\Z/ => -> v { v },
          /\Am(?:in)?s?\Z/ => -> v { v * 60 },
          /\Ah(?:our)?s?\Z/ => -> v { v * 3600 }
        })
      end
    end

  end
end
