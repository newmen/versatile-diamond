module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Provides base operations for C++ expressions of function calls
        class FunctionCall < Statement
          extend InitValuesChecker
          include Expression
          include Callable

          class << self
            # @param [String] name
            # @param [Array] args
            # @param [Hash] kwargs
            # @return [FunctionCall]
            def [](name, *args, **kwargs)
              if !str?(name)
                arg_err!("Wrong type of function name #{name.inspect}")
              elsif empty?(name)
                arg_err!('Calling function name cannot be empty')
              elsif !call_args?(args)
                arg_err!("Invalid arguemnts #{args.inspect} for #{name} function call")
              elsif !template_args?(kwargs)
                insp_args = kwargs[:template_args].inspect
                msg = "Invalid template arguments #{insp_args} for #{name} function"
                arg_err!(msg)
              else
                super
              end
            end
          end

          attr_reader :name
          def_delegator :value, :code

          # @param [String] name
          # @param [Array] args the list of expressions
          # @option [Array] :template_args the list of expressions
          def initialize(name, *args, template_args: [])
            @name = Constant[name].freeze
            @args = args.freeze
            @template_args = template_args.freeze
          end

          # @param [Array] vars
          # @return [Array] constant does not use any variable
          # @override
          def using(vars)
            @args.flat_map { |arg| arg.using(vars) }.uniq
          end

          # @return [Boolean]
          # @override
          def call?
            true
          end

        private

          # @return [OpCombine]
          def value
            full_name + OpRoundBks[OpSequence[*@args]]
          end

          # @return [Statement] name with template arguments if them are presented
          def full_name
            if @template_args.empty?
              name
            else
              name + OpAngleBks[OpSequence[*@template_args]]
            end
          end
        end

      end
    end
  end
end
