module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # The unit for combines statements of creation major instances
        # @abstract
        class MainCreationUnit < BaseCreationUnit
          # @param [Expressions::VarsDictionary] dict
          # @param [BaseContextProvider] context
          # @param [SoughtClass] creating_instance
          def initialize(dict, context, creating_instance)
            super(dict)
            @context = context
            @creating_class_name = creating_instance.class_name
          end

        private

          # @return [Array]
          def grep_context_species
            @context.bone_nodes.map(&:uniq_specie).uniq
          end

          # @param [Array] exprs
          # @return [Expressions::Core::FunctionCall]
          def call_create(*exprs)
            type = Expressions::Core::ObjectType[@creating_class_name]
            kwargs = { template_args: [type] }
            Expressions::Core::FunctionCall['create', *exprs, **kwargs].freeze
          end
        end

      end
    end
  end
end
