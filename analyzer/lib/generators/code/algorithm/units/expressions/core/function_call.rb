module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Provides base operations for C++ expressions of function calls
        class FunctionCall < Statement
          extend InitValuesChecker
          include Expression

          class << self
            # @param [String] name
            # @param [Array] args
            # @param [Array] kwargs
            # @return [FunctionCall]
            def [](name, *args, **kwargs)
              if !str?(name)
                raise "Wrong type of function name #{name.inspect}"
              elsif empty?(name)
                raise 'Calling function name cannot be empty'
              elsif kwargs[:target] && !kwargs[:target].is_a?(Variable)
                raise "Invalid target #{kwargs[:target].inspect} to call the function"
              else
                super
              end
            end
          end

          # @param [String] name
          # @param [Array] args the list of expressions
          # @option [Array] :template_args the list of expressions
          # @option [Variable] :target to which the call will be applied
          def initialize(name, *args, template_args: [], target: nil)
            @target = target
            @name = name.freeze
            @args = args.freeze
            @template_args = template_args.freeze
          end

          # @return [String] string with function call expression
          def code
            value.code
          end

        private

          # @return [Statement]
          def name
            @target ? OpCall[@target, Constant[@name]] : Constant[@name]
          end

          # @return [Statement] name with template arguments if them are presented
          def full_name
            if @template_args.empty?
              name
            else
              name + OpAngleBks[OpSequence[*@template_args]]
            end
          end

          # @return [Statement]
          def value
            full_name + OpRoundBks[OpSequence[*@args]]
          end
        end

      end
    end
  end
end
