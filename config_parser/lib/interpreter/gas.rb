module VersatileDiamond
  module Interpreter

    # Interprets gas block
    class Gas < Phase

      # Setup gas temperature by termperature expression
      # @param [Float] value the termerature of gas phase
      # @param [String] dimension of termperature
      def temperature(value, dimension = nil)
        Tools::Config.gas_temperature(value, dimension)
      end

      # Setup concentration values in gase phase for specified spec
      # @param [String] specified_spec_str the string which describe matching
      #   specific spec
      # @param [Float] value the concentration of spec in gas phase
      # @param [String] dimension of concentration
      # TODO: move this method to super class
      def concentration(specified_spec_str, value, dimension = nil)
        specific_spec = SpecificSpec.new(specified_spec_str)
        unless specific_spec.is_gas?
          syntax_error('.undefined_spec', name: specific_spec)
        end

        Tools::Config.concentration(specific_spec, value, dimension)
      end

    private

      def interpreter_class
        Interpreter::GasSpec
      end

      def concept_class
        Concepts::GasSpec
      end
    end

  end
end
