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
    end

  end
end
