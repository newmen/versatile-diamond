module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # The unit for combines statements of creation
        # @abstract
        class BaseCreationUnit < GenerableUnit
          # @param [Expressions::VarsDictionary] dict
          # @param [BaseContextProvider] context
          # @param [SoughtClass] creating_instance
          def initialize(dict, context, creating_instance)
            super(dict)
            @context = context
            @creating_class_name = creating_instance.class_name

            @_source_species = nil
          end

        private

          # @return [Array]
          def source_species
            @_source_species ||= grep_context_species.sort
          end

          # @return [Array]
          def grep_context_species
            @context.bone_nodes.map(&:uniq_specie).uniq
          end

          # @yield incorporating statement
          # @return [Expressions::Core::Statement]
          def redefine_source_species_as_array(&block)
            if same_arr?(source_species, type: abstract_type)
              block.call
            else
              remake_source_species_as_array.define_var + block.call
            end
          end

          # @return [Expressions::Core::FunctionCall]
          def create_with_source_species
            call_create(dict.var_of(source_species))
          end

          # @return [Expressions::Core::Collection]
          def remake_source_species_as_array
            values = vars_for(source_species)
            kwargs = {
              name: source_specie_name,
              next_name: false,
              type: abstract_type,
              value: values
            }
            dict.make_specie_s(source_species, **kwargs)
          end

          # @return [Expressions::Core::FunctionCall]
          def call_create(*exprs)
            type = Expressions::Core::ObjectType[@creating_class_name]
            Expressions::Core::FunctionCall['create', *exprs, template_args: [type]]
          end

          # @param [Array] instances
          # @option [Expressions::Core::ScalarType] :type
          # @return [Boolean]
          def same_arr?(instances, type: nil)
            if instances.one?
              true
            else
              arr = dict.var_of(instances)
              if arr && type && arr.type != type.ptr
                false
              else
                arr && arr.items.map(&:instance) == instances # same order
              end
            end
          end
        end

      end
    end
  end
end
