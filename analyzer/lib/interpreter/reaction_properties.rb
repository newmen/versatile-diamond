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
      end

      %w(forward reverse).each do |dir|
        # Interpret #{dir} activation energy line
        # @param [Float] value the value of activation energy
        # @param [String] dimension the dimension of activation energy
        define_method(:"#{dir}_activation") do |value, dimension = nil|
          send(dir).activation =
            Tools::Dimension.convert_energy(value, dimension)
        end

        # Interpret #{dir} rate line
        # @param [Float] value the value of pre-exponencial factor
        # @param [String] dimension the dimension of rate
        define_method(:"#{dir}_rate") do |value, dimension = nil|
          gases_num = send(dir).gases_num
          send(dir).rate = Tools::Dimension.convert_rate(
            eval_value_if_string(value, gases_num), gases_num, dimension)
        end

        # Interpret #{dir} power of temperature line
        # @param [Float] value the value of temperature power
        define_method(:"#{dir}_tpow") do |value|
          send(dir).temp_power = value.to_f
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
        unless @reverse_was_stored
          store(forward.reverse)
          @reverse_was_stored = true
        end
        forward.reverse
      rescue Concepts::LateralReaction::ReversingError => e
        syntax_error('lateral_reaction.amorph_reverse_atom',
          spec: e.spec.name, atom: e.keyname)
      end

      # Evaluate value if it passed as formula
      # @param [Float] value the evaluating value
      # @param [Integer] gases_num number of gases in evaluating case
      def eval_value_if_string(value, gases_num)
        if value.is_a?(String)
          t_str = "t = #{Tools::Config.current_temperature(gases_num)}"
          eval("#{t_str}; #{value.gsub('T', 't')}")
        else
          value
        end
      end
    end

  end
end
