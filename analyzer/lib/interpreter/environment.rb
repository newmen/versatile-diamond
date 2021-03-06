module VersatileDiamond
  module Interpreter

    # Interprets environment block
    class Environment < ComplexComponent
      include SpecificSpecMatcher

      # Initialize environment intepreter instance by environment concept
      # @param [Concepts::Environment] concept the environment concept
      def initialize(environment)
        @env = environment
      end

      # Interprets targets line and setup concept for passed atom aliases
      # @param [Array] names the array of names aliases of target atoms
      def targets(*names)
        @env.targets = names
      end

      # Interpret aliases line and store result to internal variable
      # @param [Hash] refs the hash where each key is aliased name of spec and
      #   value is aliased specific spec string
      # @raise [Errors::SyntaxError] if spec cannot be resolved
      def aliases(**refs)
        @names_and_specs = refs.each_with_object({}) do |(name, spec_str), h|
          h[name] = match_specific_spec(spec_str) { |nm| get(:spec, nm) }
        end
      end

      # Interprets where line, creates where concept and store it to Chest.
      # Pass created where concept to where interpreter and nest it.
      #
      # @param [String] name the name of where concept
      # @param [String] description the description of where concept
      # @raise [Errors::SyntaxError] if where with same name in it
      #   environment already stored
      def where(name, description)
        concept = Concepts::Where.new(name, description)
        store(@env, concept)
        nested(Where.new(@env, concept, @names_and_specs || {}))
      end
    end

  end
end
