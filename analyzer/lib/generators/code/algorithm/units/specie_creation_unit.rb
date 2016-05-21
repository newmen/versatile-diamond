module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # The unit for combines statements of specie creation
        class SpecieCreationUnit < MainCreationUnit
          include SpecieAbstractType

          # @param [Array] _
          # @param [Specie] specie
          def initialize(*, specie)
            super
            @major_atoms = specie.sequence.short
            @addition_atoms = specie.sequence.addition_atoms
          end

          # @return [Expressions::Core::Statement]
          def create
            if !source_species.empty? && all_defined?(source_species)
              create_from_source_species
            elsif all_defined?(@major_atoms)
              create_from_major_atoms
            else
              # raise 'Not all required entities were defined'
              Expressions::Core::Constant['NOT_ALL_ENTITIES_DEFINED']
            end
          end

        private

          # @return [String]
          def source_specie_name
            Code::Specie::ANCHOR_SPECIE_NAME
          end

          # @return [Array]
          # @override
          def grep_context_species
            super.reject(&:none?)
          end

          # @param [Array] atoms
          # @param [Hash] kwargs
          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def redefine_atoms_as_array(atoms, **kwargs, &block)
            if same_arr?(atoms)
              block.call
            else
              remake_atoms_as_array(atoms, **kwargs).define_var + block.call
            end
          end

          # @return [Expressions::Core::Statement]
          def create_from_major_atoms
            redefine_atoms_as_array(@major_atoms) do
              call_create(dict.var_of(@major_atoms))
            end
          end

          # @return [Expressions::Core::Statement]
          def create_from_source_species
            redefine_source_species_as_array do
              if @addition_atoms.empty?
                create_with_source_species
              else
                create_with_additional_atoms
              end
            end
          end

          # @return [Expressions::Core::Statement]
          def create_with_additional_atoms
            kwargs = { name: 'additionalAtom', next_name: false }
            redefine_atoms_as_array(@addition_atoms, **kwargs) do
              call_create(dict.var_of(@addition_atoms), dict.var_of(source_species))
            end
          end

          # @param [Array] atoms
          # @param [Hash] kwargs
          # @return [Expressions::Core::Collection]
          def remake_atoms_as_array(atoms, **kwargs)
            dict.make_atom_s(atoms, **kwargs, value: vars_for(atoms))
          end
        end

      end
    end
  end
end
