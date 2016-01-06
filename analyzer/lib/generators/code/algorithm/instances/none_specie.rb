module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Instances

        # Provides specie which means "no specie"
        class NoneSpecie < SpecialCase
          include SpecieInstance

          # Intializes the none specie
          # @param [EngineCode] generator the major code generator
          # @param [Specie] original which is original and will be remembered
          def initialize(generator, original)
            super(original)
            @generator = generator
          end

          # "No specie" is always "no specie"
          # @return [Boolean] true
          def none?
            true
          end

          # "No specie" is not scope
          # @return [Boolean] false
          def scope?
            false
          end

          def inspect
            "none:#{original.inspect}"
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
