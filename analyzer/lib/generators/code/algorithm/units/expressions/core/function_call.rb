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
            # @param [Hash] kwargs
            # @return [FunctionCall]
            def [](name, *args, **kwargs)
              if !str?(name)
                raise "Wrong type of function name #{name.inspect}"
              elsif empty?(name)
                raise 'Calling function name cannot be empty'
              elsif !args.all?(&:expr?)
                insp_args = args.reject(&:expr?).inspect
                raise "Invalid arguemnts #{insp_args} for #{name} function call"
              elsif kwargs[:target] && !kwargs[:target].var?
                raise "Invalid target #{kwargs[:target].inspect} to call the function"
              else
                is_tmpl = -> arg { arg.scalar? || arg.type? }
                if kwargs[:template_args] && !kwargs[:template_args].all?(&is_tmpl)
                  insp_args = kwargs[:template_args].reject(&is_tmpl).inspect
                  raise "Invalid template arguments #{insp_args} for #{name} function"
                else
                  super
                end
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

          # @return [Statement]
          def name
            Constant[@name]
          end

        private

          # @return [Statement]
          def value
            full_name + OpRoundBks[OpSequence[*@args]]
          end

          # @return [Statement] name with template arguments if them are presented
          def full_name
            if @template_args.empty?
              name_with_target
            else
              name_with_target + OpAngleBks[OpSequence[*@template_args]]
            end
          end

          # @return [Statement]
          def name_with_target
            @target ? OpCall[@target, name] : name
          end

          # @param [Array] vars
          # @return [Array] constant does not use any variable
          # @override
          def using(vars)
            result = @args.flat_map { |arg| arg.using(vars) }
            @target && vars.include?(@target) ? (result << @target) : result
          end
        end

      end
    end
  end
end
