module VersatileDiamond
  module Interpreter

    # Interprets reaction properties and pass it to concept instance
    module ReactionProperties

      # Arrenius equation:
      #
      #   k = A * exp(-Ea/RT)
      #   A = a * (T ** x)
      #
      # where
      #   RT = R * T,
      #   R = 8.31 J/(mol * K) - gas constant
      #   T - environment temperature
      #   Ea - activation energy (barrier)
      #   A - frequency factor of the reaction
      #   a - collisions rate
      #   x - power of temperature

      # Interpret enthalpy line
      # @param [Float] value the value of enthalpy
      # @param [String] dimension the dimension of enthalpy
      def enthalpy(value, dimension = nil)
        converted_value = Tools::Dimension.convert_energy(value, dimension)
        forward.enthalpy = converted_value
        reverse.enthalpy = -converted_value
      rescue Concepts::UbiquitousReaction::AlreadySet => e
        already_set_error(e)
      end

      # Interpret activation line and setup forward and reverse activation
      # energy for concept
      #
      # @param [Float] value the value of activation energy
      # @param [String] dimension the dimension of activation energy
      def activation(value, dimension = nil)
        converted_value = Tools::Dimension.convert_energy(value, dimension)
        forward.activation = converted_value
        reverse.activation = converted_value
      rescue Concepts::UbiquitousReaction::AlreadySet => e
        already_set_error(e)
      end

      %w(forward reverse).each do |dir|
        # Interpret #{dir} activation energy line
        # @param [Float] value the value of activation energy
        # @param [String] dimension the dimension of activation energy
        define_method(:"#{dir}_activation") do |value, dimension = nil|
          begin
            send(dir).activation =
              Tools::Dimension.convert_energy(value, dimension)
          rescue Concepts::UbiquitousReaction::AlreadySet => e
            already_set_error(e)
          end
        end

        # Interpret #{dir} rate line
        # @param [Float | String] value the value of pre-exponencial factor
        # @param [String] dimension the dimension of rate
        define_method(:"#{dir}_rate") do |value, dimension = nil|
          begin
            gases_num = send(dir).gases_num
            rate, tp = rate_and_temperature_power(value)
            send(dir).rate = Tools::Dimension.convert_rate(rate, gases_num, dimension)
            send(dir).temp_power = tp if tp != 0
          rescue Concepts::UbiquitousReaction::AlreadySet => e
            already_set_error(e)
          end
        end

        # Interpret #{dir} power of temperature line
        # @param [Float] value the value of temperature power
        define_method(:"#{dir}_tpow") do |value|
          begin
            send(dir).temp_power = value.to_f
          rescue Concepts::UbiquitousReaction::AlreadySet => e
            already_set_error(e)
          end
        end
      end

    private

      # Represents reaction concept for forward reaction direction
      # @return [Concepts::UbiquitousReaction] current concept
      def forward
        @reaction || syntax_error('reaction.need_define_equation')
      end

      # Makes reaction concept for reverse reaction direction, cache it and
      # store it to Chest
      #
      # @return [Concepts::UbiquitousReaction] reverse of current concept
      def reverse
        if !forward.has_reverse? || !Tools::Chest.has?(forward.reverse)
          store(forward.reverse)
        end
        forward.reverse
      rescue Concepts::There::ReversingError => e
        syntax_error('lateral_reaction.amorph_reverse_atom',
          spec: e.spec.name, atom: e.keyname)
      end

      # Parse value if it passed as formula
      # @param [Float] value the parsing formula
      def rate_and_temperature_power(value)
        if !value.is_a?(String)
          [value, 0]
        else
          nb = '-?\d+(?:\.\d+)?(?:e-?\d+)?'
          rx = /\A\s*(?<k>#{nb})\s*\*\s*T(?:\s*\*\*\s*(?<pow>#{nb}))?\s*\Z/
          m = value.match(rx)
          if m
            [m[:k].to_f, (m[:pow] ? m[:pow].to_f : 1)]
          else
            syntax_error('reaction.wrong_rate_value', value: value)
          end
        end
      end

      # Shows syntax error when exception AlreadySet was raised
      # @param [Concepts::UniquitousReaction:AlreadySet] e the exception object
      def already_set_error(e)
        syntax_error('reaction.already_set',
          reaction: e.reaction.name, property: e.property, value: e.value)
      end
    end

  end
end
