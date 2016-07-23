module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Makes the lambda function statement
        class Lambda < Statement
          include Modules::ListsComparer
          include Expression

          class << self
            # @param [Array] defined_vars
            # @param [Array] arg_vars
            # @param [Expression] body
            # @return [Lambda]
            def [](defined_vars, *arg_vars, body)
              if !defined_vars
                arg_err!('Variables dictionary is not set')
              elsif !arg_vars.all?(&:var?)
                msg = "Wrong type of lambda argument variable #{arg_vars.inspect}"
                arg_err!(msg)
              else
                super
              end
            end
          end

          def_delegator :@body, :using

          # @param [Array] defined_vars
          # @param [Array] arg_vars
          # @param [Expression] body
          def initialize(defined_vars, *arg_vars, body)
            @defined_vars = defined_vars
            @arg_vars = arg_vars.freeze
            @body = body
          end

          # @return [String]
          def code
            [
              OpSquireBks[closure_vars],
              OpRoundBks[OpSequence[*@arg_vars.map(&:define_arg)]],
              OpBraces[@body]
            ].map(&:code).join
          end

          # Checks that current statement is constant
          # @return [Boolean] true
          # @override
          def const?
            true
          end

        private

          # @return [Statement]
          def closure_vars
            names = using(@defined_vars)
            if names.empty?
              Constant['']
            elsif same_as_defined?(names)
              OpRef[]
            else
              OpSequence[*references_of(names)]
            end
          end

          # @param [Array] names
          # @return [Boolean]
          def same_as_defined?(names)
            lists_are_identical?(names, @defined_vars.reject(&:item?).map(&:name))
          end

          # @param [Array] names
          # @return [Array]
          def references_of(names)
            names_dup = names.dup
            this = names_dup.delete_one { |name| name.code == This::NAME }
            refs = reorder_vars(names_dup).map(&OpRef.public_method(:[]))
            this ? [this] + refs : refs
          end

          # @param [Array] names
          # @return [Array]
          def reorder_vars(names)
            names.sort_by(&:code)
          end
        end

      end
    end
  end
end
