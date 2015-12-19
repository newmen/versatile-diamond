module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Instances

        # Represents the special case of unique parent specie instance
        # @abstract
        class SpecialCase
          include SpecieInstance
          extend Forwardable

          attr_reader :original
          def_delegator :original, :spec

          # Initialize special case
          # @param [EngineCode] generator the major code generator
          # @param [Specie] original which is original and will be remembered
          def initialize(generator, original)
            @generator = generator
            @original = original
          end

        private

          attr_reader :generator

          # Gets the atom which was passed
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which will be returned
          # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   the passed atom
          %i(original_atom reflection_of).each do |method_name|
            define_method(method_name) { |atom| atom }
          end
        end

      end
    end
  end
end
