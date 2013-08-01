module VersatileDiamond
  module Interpreter

    # Interprets equation properties and pass it to concept instance
    # TODO: rspec
    module EquationProperties
      include Modules::BoundaryTemperature

      # Interpret enthalpy line
      # @param [Float] value the value of enthalpy
      # @param [String] dimension the dimension of enthalpy
      def enthalpy(value, dimension = nil)
        @concept.enthalpy = Tools::Dimension.convert_energy(value, dimension)
      end

      # Interpret activation line and setup forward and reverse enthalpy for
      #   concept
      #
      # @param [Float] value the value of activation energy
      # @param [String] dimension the dimension of activation energy
      def activation(value, dimension = nil)
        activation = Tools::Dimension.convert_energy(value, dimension)
        @concept.forward_activation = activation
        @concept.reverse_activation = activation
      end

      # Interpret forward activation energy line
      # @param [Float] value the value of activation energy
      # @param [String] dimension the dimension of activation energy
      def forward_activation(value, dimension = nil)
        @concept.forward_activation =
          Tools::Dimension.convert_energy(value, dimension)
      end

      # Interpret reverse activation energy line
      # @param [Float] value the value of activation energy
      # @param [String] dimension the dimension of activation energy
      def reverse_activation(value, dimension = nil)
        @concept.reverse_activation =
          Tools::Dimension.convert_energy(value, dimension)
      end

      # Interpret forward rate line
      # @param [Float] value the value of pre-exponencial factor
      # @param [String] dimension the dimension of rate
      def forward_rate(value, dimension = nil)
        gases_num = @concept.source_gases_num
        @concept.forward_rate = Tools::Dimension.convert_rate(
            eval_value_if_string(value, gases_num), gases_num, dimension)
      end

      # Interpret reverse rate line
      # @param [Float] value the value of pre-exponencial factor
      # @param [String] dimension the dimension of rate
      def reverse_rate(value, dimension = nil)
        gases_num = @concept.products_gases_num
        @concept.reverse_rate = Tools::Dimension.convert_rate(
            eval_value_if_string(value, gases_num), gases_num, dimension)
      end

    private

      # Evaluate value if it passed as formula
      # @param [Float] value the evaluating value
      # @param [Integer] gases_num number of gases in evaluating case
      def eval_value_if_string(value, gases_num)
        if value.is_a?(String)
          t_str = "T = #{current_temperature(gases_num)}"
          eval("#{t_str}; #{value}")
        else
          value
        end
      end
    end

  end
end
