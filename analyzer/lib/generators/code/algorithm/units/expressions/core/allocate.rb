module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Provides base operations for C++ memory allocation
        class Allocate < Statement
          include Expression

          class << self
            # @param [ObjectType] type
            # @param [Array] args
            # @param [Hash] kwargs
            # @return [Allocate]
            def [](type, *args, **kwargs)
              if !type.type? || type.scalar?
                arg_err!("Wrong type #{type.inspect}")
              else
                super
              end
            end
          end

          def_delegator :@constructor_call, :using

          # @param [ObjectType] type
          # @param [Array] args the list of expressions
          # @param [Hash] kwargs
          def initialize(type, *args, **kwargs)
            @constructor_call = FunctionCall[type.name, *args, **kwargs]
          end

          # @return [String]
          def code
            "new #{@constructor_call.code}"
          end
        end

      end
    end
  end
end
