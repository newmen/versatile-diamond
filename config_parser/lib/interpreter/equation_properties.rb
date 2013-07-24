module VersatileDiamond

  module Interpreter

    module EquationProperties
      include Modules::BoundaryTemperature

      def enthalpy(value, dimension = nil)
        equation_instance.enthalpy = Dimensions.convert_energy(value, dimension)
      end

      def activation(value, dimension = nil)
        activation = Dimensions.convert_energy(value, dimension)
        equation_instance.forward_activation = activation
        equation_instance.reverse_activation = activation
      end

      def forward_activation(value, dimension = nil)
        equation_instance.forward_activation =
          Dimensions.convert_energy(value, dimension)
      end

      def reverse_activation(value, dimension = nil)
        equation_instance.reverse_activation =
          Dimensions.convert_energy(value, dimension)
      end

      def forward_rate(value, dimension = nil)
        gases_num = equation_instance.source_gases_num
        equation_instance.forward_rate =
          Dimensions.convert_rate(
            eval_value_if_string(value, gases_num), gases_num, dimension)
      end

      def reverse_rate(value, dimension = nil)
        gases_num = equation_instance.products_gases_num
        equation_instance.reverse_rate =
          Dimensions.convert_rate(
            eval_value_if_string(value, gases_num), gases_num, dimension)
      end

    private

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
