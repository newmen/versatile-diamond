module VersatileDiamond
  module Interpreter

    # Interprets gas block
    class Gas < Phase
      include SpecificSpecMatcher

      # Setup concentration values in gase phase for specified spec
      # @param [String] specified_spec_str the string which describe matching
      #   specific spec
      # @param [Float] value the concentration of spec in gas phase
      # @param [String] dimension of concentration
      # @raise [Errors::SyntaxError] if spec is undefined or if concentration
      #   of specified spec already defined
      # TODO: move this method to super class ;)
      def concentration(specified_spec_str, value, dimension = nil)
        specific_spec = detect_spec(specified_spec_str)
        Tools::Config.gas_concentration(specific_spec, value, dimension)
      rescue Tools::Config::AlreadyDefined
        syntax_error('.concentration_already_set', name: specific_spec.name)
      end

    private

      # Detects the specified spec by finding a base spec from gas specs scope
      # @param [String] specific_spec_str the analyzing specific spec string
      # @raise [Errors::SyntaxError]
      # @return [Concepts::SpecificSpec] instance of specific spec
      def detect_spec(specified_spec_str)
        match_specific_spec(specified_spec_str) do |name|
          get(:gas_spec, name)
        end
      end

      def interpreter_class
        Interpreter::GasSpec
      end

      def concept_class
        Concepts::GasSpec
      end
    end

  end
end
