module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Provides base operations for C++ expressions of class types
        class ObjectType < ScalarType
          class << self
            # @param [Object] name
            # @param [Hash] kwargs
            # @return [ScalarType]
            def [](name, **kwargs)
              if !template_args?(kwargs)
                insp_args = kwargs[:template_args].inspect
                arg_err!("Invalid template arguments #{insp_args} for #{name} type")
              else
                super
              end
            end
          end

          # @param [String] name
          # @option [Array] :template_args the list of expressions
          def initialize(name, template_args: [])
            super(name)
            @template_args = template_args.freeze
          end

          # @return [String]
          # @override
          def code
            full_name
          end

          # Checks that current type is scalar pointer
          # @return [Boolean]
          def scalar?
            false
          end

          # @param [Array] args
          # @param [Hash] kwargs
          # @return [OpNs]
          def call(*args, **kwargs)
            OpNs[self, FunctionCall[*args, **kwargs]]
          end

          # @param [FunctionCall] expr
          # @return [OpRef] the name of type with reference to member
          def member_ref(expr)
            OpRef[OpNs[self, expr.call? ? expr.name : expr]]
          end

        private

          # @return [String] name with template arguments if them are presented
          def full_name
            if @template_args.empty?
              value
            else
              value + OpAngleBks[OpSequence[*@template_args]].code
            end
          end
        end

      end
    end
  end
end
