module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Instances

        # Provides specie which means "no specie"
        class NoneSpecie < SpecialCase
          include SpecieInstance

          def_same_atom_method :context_atom

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

          # "No specie" is always actual anchor
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom] _
          # @return [Boolean] true
          def actual_anchor?(_)
            true
          end

          def inspect
            "none:#{original.inspect}"
          end

        private

          attr_reader :generator

          def_same_atom_method :original_atom, :reflection_of

        end

      end
    end
  end
end
