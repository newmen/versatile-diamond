using VersatileDiamond::Patches::RichString

module VersatileDiamond
  module Interpreter

    # Interprets gas or surface block, and specify spec block in both
    # @abstract
    class Phase < ComplexComponent

      # Interprets spec block, creates correspond spec and nesting it
      # @param [Symbol] name the name of spec
      # @return [Concepts::Spec] the result of interpretation
      def spec(name)
        concept_spec = concept_class.new(name)
        store(concept_spec)
        nested(interpreter_class.new(concept_spec))
      end

      # Setup correspond temperature by termperature expression
      # @param [Float] value the termerature of correspond phase
      # @param [String] dimension of termperature
      # @raise [Errors::SyntaxError] if temperature already defined
      def temperature(value, dimension = nil)
        Tools::Config.send(
          "#{self.class.to_s.underscore}_temperature", value, dimension)
      rescue Tools::Config::AlreadyDefined
        syntax_error('.temperature_already_set')
      end
    end

  end
end
