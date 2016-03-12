module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        # Represents specie variable statement
        class SpecieVariable < Core::Variable
          class << self
            # @param [NameRemember] namer
            # @param [Object] instance
            # @param [Core::Expression] value
            # @option [String] :name
            # @option [String] :type
            # @return [SpecieVariable]
            def [](namer, instance, value = nil, name: nil, type: nil)
              name ||= instance.var_name
              type ||= ObjectType[instance.original.class_name].ptr
              super(namer, instance, type, name, value)
            end
          end

          # @param [Core::Expression] body
          # @param [Core::ObjectType] inner_type
          # @return [SpecieVariable, Core::FunctionCall]
          def iterate_symmetries(inner_type, body)
            inner_var, arg = iteration_lambda(body, inner_type: inner_type)
            func_call = call('eachSymmetry', arg)
            [inner_var, func_call]
          end

        private

          # @param [Core::Expression] body
          # @param [Hash] topts
          # @return [SpecieVariable, Core::Lambda]
          def iteration_lambda(body, **topts)
            inner_var = iterable_var(**topts)
            [inner_var, Core::Lambda[namer, inner_var, body]]
          end

          # @option [Core::ObjectType] :inner_type
          # @return [SpecieVariable]
          def iterable_var(inner_type: nil)
            inner_type = inner_type ? inner_type.ptr : type
            self.class[namer, instance, type: inner_type]
          end
        end

      end
    end
  end
end
