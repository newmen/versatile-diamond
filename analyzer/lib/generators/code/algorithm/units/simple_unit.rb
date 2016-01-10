module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # The base class for algorithm builder units with one original specie
        class SimpleUnit < BaseUnit

          # Initializes the simple unit of code builder algorithm
          # @param [EngineCode] generator the major code generator
          # @param [NameRemember] namer the remember of using names of variables
          # @param [Organizers::DependentWrappedSpec] original_spec which uses in
          #   current building algorithm
          # @param [Array] atoms the array of target atoms
          def initialize(generator, namer, original_spec, atoms)
            super(generator, namer, atoms)
            @original_spec = original_spec
          end

        protected

          attr_reader :original_spec

          # Selects most complex target atom
          # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   the most target atom of original specie
          def target_atom
            @_target_atom ||=
              atoms.max_by { |atom| atom_properties(original_spec, atom) }
          end

          # Gets dependent spec for passed atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   _ does not used
          # @return [Organizers::DependentWrappedSpec] the internal dependent spec
          def dept_spec_for(_)
            original_spec
          end

        private

          # Gets the original specie code generator
          # @return [Specie] the original specie code generator
          def original_specie
            specie_class(original_spec)
          end
        end

      end
    end
  end
end
