module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # The base class for algorithm builder units with one original specie
        # @abstract
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

          # Checks that atom has a bond like the passed
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which relations in current specie will be checked
          # @param [Concepts::Bond] bond which existance will be checked
          # @return [Boolean] is atom uses bond in current specie or not
          def use_bond?(atom, bond)
            original_spec.relations_of(atom).any? { |r| r == bond }
          end

        protected

          attr_reader :original_spec

          # Selects most complex target atom
          # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   the most target atom of original specie
          def target_atom
            @_target_atom ||= atoms.max_by do |atom|
              Organizers::AtomProperties.new(original_spec, atom)
            end
          end

        private

          # Gets the original specie code generator
          # @return [Specie] the original specie code generator
          def original_specie
            specie_class(original_spec)
          end

          # Gets the variable name of target atom
          # @return [String] the variable name of target atom
          def target_atom_var_name
            namer.name_of(target_atom)
          end

          # Gets the index of passed atom from generator's classifer by original spec
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which will be classified
          # @return [Integer] the role of passed atom
          def role(atom)
            generator.classifier.index(original_spec, atom)
          end
        end

      end
    end
  end
end
