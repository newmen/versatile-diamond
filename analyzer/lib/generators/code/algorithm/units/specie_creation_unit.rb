module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # The unit for combines statements of specie creation
        class SpecieCreationUnit < GenerableUnit
          # @param [Expressions::VarsDictionary] dict
          # @param [BaseContext] context
          # @param [Specie] specie
          def initialize(dict, context, specie)
            super(dict)
            @specie = specie

            @major_atoms = @specie.sequence.short
            @addition_atoms = @specie.sequence.addition_atoms
            @parent_species =
              context.bone_nodes.map(&:uniq_specie).reject(&:none?).uniq.sort
          end

          # @return [Expressions::Core::Statement]
          def create
            if !@parent_species.empty? && all_defined?(@parent_species)
              create_from_parent_species
            elsif all_defined?(@major_atoms)
              create_from_major_atoms
            else
              raise 'Not all required entities were defined'
            end
          end

        private

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

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def redefine_parent_species_as_array(&block)
            if same_arr?(@parent_species)
              block.call
            else
              remake_parent_species_as_array.define_var + block.call
            end
          end

          # @return [Expressions::Core::Statement]
          def create_from_major_atoms
            redefine_atoms_as_array(@major_atoms) do
              call_create(dict.var_of(@major_atoms))
            end
          end

          # @return [Expressions::Core::Statement]
          def create_from_parent_species
            redefine_parent_species_as_array do
              if @addition_atoms.empty?
                create_with_parent_species
              else
                create_with_additional_atoms
              end
            end
          end

          # @return [Expressions::Core::FunctionCall]
          def create_with_parent_species
            call_create(dict.var_of(@parent_species))
          end

          # @return [Expressions::Core::Statement]
          def create_with_additional_atoms
            kwargs = { name: 'additionalAtom', next_name: false }
            redefine_atoms_as_array(@addition_atoms, **kwargs) do
              call_create(dict.var_of(@addition_atoms), dict.var_of(@parent_species))
            end
          end

          # @param [Array] atoms
          # @param [Hash] kwargs
          # @return [Expressions::Core::Collection]
          def remake_atoms_as_array(atoms, **kwargs)
            dict.make_atom_s(atoms, **kwargs, value: vars_for(atoms))
          end

          # @return [Expressions::Core::Collection]
          def remake_parent_species_as_array
            type = Expressions::ParentSpecieType[]
            values = vars_for(@parent_species)
            dict.make_specie_s(@parent_species, type: type, value: values)
          end

          # @return [Expressions::Core::FunctionCall]
          def call_create(*exprs)
            type = Expressions::Core::ObjectType[@specie.class_name]
            Expressions::Core::FunctionCall['create', *exprs, template_args: [type]]
          end

          # @param [Array] instances
          # @return [Boolean]
          def same_arr?(instances)
            if instances.one?
              true
            else
              arr = dict.var_of(instances)
              arr && arr.items.map(&:instance) == instances # same order
            end
          end
        end

      end
    end
  end
end
