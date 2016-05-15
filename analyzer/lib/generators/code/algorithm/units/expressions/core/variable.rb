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
          attr_reader :instance, :type

          # @param [Object] instance
          # @param [ScalarType] type
          # @param [String] name
          # @param [Expression] value
          def initialize(instance, type, name, value = nil)
            @instance = instance
            @type = type.freeze
            @name = Constant[name].freeze
            @value = value
          end

          # @param [Expression] new_index
          def update_index!(new_index)
            if item?
              new_name = code.sub(INDEX_RX, "[#{new_index.code}]")
              @name = Constant[new_name].freeze
            else
              raise 'Cannot update index of variable which not belongs to any array'
            end
          end

          # Checks that current statement is variable
          # @return [Boolean] true
          # @override
          def var?
            true
          end

          # @return [Boolean]
          def item?
            !!(code =~ INDEX_RX)
          end

          # Checks that current statement is object
          # @return [Boolean]
          # @override
          def obj?
            !type.scalar? || type.ptr?
          end

          # @param [Array] vars
          # @return [Array] list of using variables
          def using(vars)
            check_using = -> v { v.parent_arr?(self) }
            if vars.include?(self)
              [self]
            elsif item? && vars.any?(&check_using)
              vars.select(&check_using)
            else
              []
            end
          end

          # @return [Assign] the string with variable definition
          def define_var
            Assign[full_name, type: type, value: value]
          end

          # @return [Assign] the string with argument definition
          def define_arg
            Assign[@name, type: arg_type]
          end

        protected

          # @param [Variable] _
          # @return [Boolean] false
          def parent_arr?(_)
            false
          end

        private

          attr_reader :value

          # @return [Constant] the same name by default
          def full_name
            @name
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
