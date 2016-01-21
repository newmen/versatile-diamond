module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Provides base operations for all C++ statements
        # @abstract
        class Statement
          extend Forwardable

          TAB_SIZE = 4.freeze # always so for cpp
          TAB_SPACES = (' ' * TAB_SIZE).freeze

          class << self
            # @param [Array] exprs
            # @param [Array] kwargs
            # @return [Statement]
            def [](*exprs, **kwargs)
              kwargs.empty? ? new(*exprs) : new(*exprs, **kwargs)
            end
          end

          # @param [Statement]
          # @return [Statement]
          def +(other)
            if op? || other.op?
              OpCombine[self, other]
            else
              raise ArgumentError, "Cannot concate #{self} with #{other}"
            end
          end

          # Checks that current statement is expression
          # @return [Boolean] false by default
          def expr?
            false
          end

          # Checks that current statement is variable
          # @return [Boolean] false by default
          def var?
            false
          end

          # Checks that current statement is constant
          # @return [Boolean] false by default
          def const?
            false
          end

          # Checks that current statement is type
          # @return [Boolean] false by default
          def type?
            false
          end

          # Checks that current statement is operator
          # @return [Boolean] false by default
          def op?
            false
          end

          def to_s
            "\n#{code}\n"
          end

          def inspect
            # More detailed info about total expression
            "␂#{code}␃"
          end

        private

          # @param [String] str to which the semicolon will be added
          # @return [String] the string with code which ends with semicolon
          def wrap(str)
            "#{TAB_SPACES}#{str};"
          end
        end

      end
    end
  end
end
