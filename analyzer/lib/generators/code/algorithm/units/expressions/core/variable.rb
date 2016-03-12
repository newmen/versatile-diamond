module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Provides base operations for C++ expressions of variables
        class Variable < Statement
          extend InitValuesChecker
          include Expression

          class << self
            # @param [Object] instance
            # @param [ScalarType] type
            # @param [String] name
            # @param [Expression] value
            # @return [Variable]
            def [](instance, type, name, value = nil)
              if !instance || (arr?(instance) && instance.empty?)
                arg_err!('Instance of variable is not set')
              elsif !type.type?
                arg_err!("Wrong variable type #{type.inspect}")
              elsif value && !valid?(instance, value)
                arg_err!("Wrong type of variable value #{value.inspect}")
              elsif name && !str?(name)
                arg_err!("Wrong type of variable name #{name.inspect}")
              elsif name && empty?(name)
                arg_err!('Name of variable cannot be empty')
              else
                super
              end
            end

          private

            # @param [Object | Array] instance
            # @param [Expression | Array] value
            # @return [Boolean]
            def valid?(instance, value)
              (arr?(instance) && arr?(value) && value.all?(&:expr?)) ||
                (!arr?(instance) && value.expr?)
            end
          end

          def_delegator :@name, :code
          attr_reader :instance

          # @param [Object] instance
          # @param [ScalarType] type
          # @param [String] name
          # @param [Expression] value
          def initialize(instance, type, name, value = nil)
            @instance = instance.freeze
            @type = type.freeze
            @name = Constant[name].freeze
            @value = value && value.freeze
          end

          # Checks that current statement is variable
          # @return [Boolean] true
          # @override
          def var?
            true
          end

          # Checks that current statement is object
          # @return [Boolean]
          # @override
          def obj?
            !type.scalar? || type.ptr?
          end

          # @param [Array] vars
          # @return [Array] list of using variables
          # @override
          def using(vars)
            current, next_vars = self_using(vars)
            current + (value ? value.using(next_vars) : [])
          end

          # @return [Assign] the string with variable definition
          def define_var
            Assign[full_name, type: type, value: value]
          end

          # @return [Assign] the string with argument definition
          def define_arg
            Assign[@name, type: arg_type]
          end

          # @param [String] method_name
          # @param [Array] args
          # @param [Hash] kwargs
          # @return [OpCall] the string with method call
          def call(method_name, *args, **kwargs)
            OpCall[self, FunctionCall[method_name, *args, **kwargs]]
          end

        private

          attr_reader :type, :value

          # @return [Constant] the same name by default
          def full_name
            @name
          end

          # @return [ScalarType]
          def arg_type
            type
          end

          # @param [Array] vars
          # @return [Array]
          def self_using(vars)
            vars.include?(self) ? [[self], vars - [self]] : [[], vars]
          end
        end

      end
    end
  end
end
