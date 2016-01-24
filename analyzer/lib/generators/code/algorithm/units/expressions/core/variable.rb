module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Provides base operations for C++ expressions of variables
        class Variable < Statement
          extend InitValuesChecker
          include Expression

          class << self
            # @param [NameRemember] namer
            # @param [Object] instance
            # @param [Type] type
            # @param [String] name
            # @param [Expression] value
            # @param [Hash] nopts
            # @return [Variable]
            def [](namer, instance, type, name = nil, value = nil, **nopts)
              if !namer
                raise 'Name remember is not set'
              elsif !instance
                raise 'Instance of variable is not set'
              elsif !type.type?
                raise "Wrong variable type #{type.inspect}"
              elsif value && !valid?(instance, value)
                raise "Wrong type of variable value #{value.inspect}"
              elsif name && !str?(name)
                raise "Wrong type of variable name #{name.inspect}"
              elsif name && empty?(name)
                raise 'Name of variable cannot be empty'
              else
                super
              end
            end

            # Assigns the name of variable to instance
            # @return [String] the assigned name of variable
            def assign_name(namer, definig_instance, assigning_name, next_name: true)
              namer_method_name = next_name ? :assign_next : :assign
              namer.public_send(namer_method_name, definig_instance, assigning_name)
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

          def_delegator :name, :code

          # @param [NameRemember] namer
          # @param [Object] instance
          # @param [Type] type
          # @param [String] name
          # @param [Expression] value
          # @param [Hash] nopts
          def initialize(namer, instance, type, name = nil, value = nil, **nopts)
            @namer = namer
            @instance = instance.freeze
            @type = type.ptr.freeze
            @value = value && value.freeze

            if name && !used_name
              self.class.assign_name(namer, instance, name, **nopts)
            end
          end

          # Checks that current statement is variable
          # @return [Boolean] true
          # @override
          def var?
            true
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
            Assign[full_name, type: @type, value: value]
          end

          # @return [Assign] the string with argument definition
          def define_arg
            Assign[name, type: arg_type]
          end

          # @param [String] method_name
          # @param [Array] args
          # @param [Hash] kwargs
          # @return [OpCall] the string with method call
          def call(method_name, *args, **kwargs)
            OpCall[self, FunctionCall[method_name, *args, **kwargs]]
          end

        private

          attr_reader :value

          # @return [Constant] the name of variable
          # @override
          def name
            if used_name
              Constant[used_name]
            else
              raise "Name was not assigned to #{@instance.inspect}"
            end
          end

          # @return [Constant] the same name by default
          def full_name
            name
          end

          # @return [String] the defined name of variable
          def used_name
            @namer.name_of(@instance)
          end

          # @return [Type]
          def arg_type
            @type
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
