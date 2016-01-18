module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Provides base operations for C++ expressions of variables
        class Variable < Statement

          attr_reader :type, :instance

          # @param [NameRemember] namer
          # @param [Object] instance
          # @param [Type] type
          # @param [String] name
          # @param [Statement] value
          def initialize(namer, instance, type, name = nil, value = nil, **next_name)
            @namer = namer
            @instance = instance.freeze
            @type = type.ptr.freeze
            @rvalue = value && value.freeze

            assign_name!(instance, name, **next_name) unless used_name
          end

        protected

          # @return [Statement] the string with variable definition
          def define_var
            Assign[full_name, type: type, value: rvalue]
          end

          # @return [Statement] the string with argument definition
          def define_arg
            Assign[name, type: type]
          end

          # @return [Statement] the name of variable
          # @override
          def name
            if used_name
              Constant[used_name]
            else
              raise "Name was not assigned to #{instance}"
            end
          end

          # @param [Function] method
          # @param [Array] arg_exprs
          # @option [Array] :template_arg_exprs
          # @return [Statement] the string with method call
          def call(method, *arg_exprs, **termplate_arg_exprs)
            OpCall[self, method.call(*arg_exprs, **termplate_arg_exprs)]
          end

        private

          attr_reader :rvalue

          # Assigns the name of variable to instance
          # @return [String] the assigned name of variable
          def assign_name!(definig_instance, assigning_name, next_name: true)
            return nil unless assigning_name
            namer_method_name = @is_need_to_assign_next_name ? :assign_next : :assign
            @namer.public_send(namer_method_name, definig_instance, assigning_name)
          end

          # @return [Statement] the same name by default
          def full_name
            name
          end

          # @return [String] the defined name of variable
          def used_name
            @namer.name_of(instance)
          end

          # @param [Array] vars
          # @return [Array] list of using variables
          # @override
          def using(vars)
            current = (vars.include?(self) ? [self] : [])
            current + (rvalue ? rvalue.using(vars - current) : [])
          end
        end

      end
    end
  end
end
