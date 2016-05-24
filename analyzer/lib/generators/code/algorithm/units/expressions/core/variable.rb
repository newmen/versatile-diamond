module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Provides base operations for C++ expressions of variables
        class Variable < Statement
          extend InitValuesChecker
          include Expression
          include Callable

          INDEX_RX = /\[.+?\]$/.freeze

          class << self
            # @param [Object] instance
            # @param [ScalarType] type
            # @param [String] name
            # @option [Expression] :value
            # @option [Expression] :index
            # @return [Variable]
            def [](instance, type, name, value: nil, index: nil)
              if !instance || (arr?(instance) && instance.empty?)
                arg_err!('Instance of variable is not set')
              elsif !type.type?
                arg_err!("Wrong variable type #{type.inspect}")
              elsif value && !valid?(instance, value)
                arg_err!("Wrong type of variable value #{value.inspect}")
              elsif index && !index.expr?
                arg_err!("Wrong index value #{index.inspect}")
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

          def_delegator :full_name, :code
          attr_reader :instance, :type

          # @param [Object] instance
          # @param [ScalarType] type
          # @param [String] name
          # @option [Expression] :value
          # @option [Expression] :index
          def initialize(instance, type, name, value: nil, index: nil)
            @instance = instance
            @type = type.freeze
            @name = Constant[name].freeze
            @value = value
            @index = index
          end

          # @param [Expression] new_index
          def update_index!(new_index)
            if item?
              @index = new_index.freeze
            else
              raise 'Cannot update index of variable'
            end
          end

          # Checks that current statement is variable
          # @return [Boolean] true
          # @override
          def var?
            true
          end

          # @return [Boolean]
          def collection?
            false
          end

          # @return [Boolean]
          def item?
            !!@index
          end

          # Checks that current statement is object
          # @return [Boolean]
          # @override
          def obj?
            !type.scalar? || type.ptr?
          end

          # @return [Boolean]
          def proxy?
            false
          end

          # @param [Array] vars
          # @return [Array] list of using variables
          def using(vars)
            if vars.include?(self)
              [name]
            elsif @index # do not use #item? here
              @index.using(vars) + vars.select { |v| v.parent_arr?(self) }
            else
              []
            end
          end

          # @param [Array] constructor_args
          # @return [Assign] the string with variable definition
          def define_var(*constructor_args)
            if item?
              raise 'Cannot define a collection item separatedly'
            elsif constructor_args.empty?
              Assign[full_name, type: type, value: value]
            elsif !value
              Assign[full_name, type: type, constructor_args: constructor_args]
            else
              msg = "Cannot define var #{self} with value and constructor arguments"
              raise ArgumentError, msg
            end
          end

          # @return [Assign] the string with argument definition
          def define_arg
            if item?
              raise 'Cannot define a collection item separatedly'
            else
              Assign[name, type: arg_type]
            end
          end

        protected

          # @param [Variable] _
          # @return [Boolean] false
          def parent_arr?(_)
            false
          end

        private

          attr_reader :name, :value

          # @return [Constant] the same name by default
          def full_name
            # do not use #item? here too
            @index ? name + OpSquireBks[@index] : name
          end

          # @return [ScalarType]
          def arg_type
            type
          end
        end

      end
    end
  end
end
