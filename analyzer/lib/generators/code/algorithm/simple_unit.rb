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

          # Gets dependent spec for passed atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   _ does not used
          # @return [Organizers::DependentWrappedSpec] the internal dependent spec
          def dept_spec_for(_)
            original_spec
          end

          # By default doesn't need to define anchor atoms for each crystal neighbours
          # operation
          #
          # @return [String] the empty string
          def define_nbrs_specie_anchors_lines
            ''
          end
        end

      end
    end
  end
end
