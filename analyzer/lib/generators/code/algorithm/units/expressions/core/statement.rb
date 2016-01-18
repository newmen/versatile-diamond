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
            # @param [Array] exprs to which the operation will be applied
            # @return [Statement]
            def [](*exprs, **kwargs)
              kwargs.empty? ? new(*exprs) : new(*exprs, **kwargs)
            end
          end

          # @param [Statement]
          # @return [Statement]
          def +(other)
            if mergeable?(a, b)
              OpCombine[self, other]
            else
              raise ArgumentError, "Cannot concate #{code} with #{other.code}"
            end
          end

          def to_s
            "\n#{code}\n"
          end

          def inspect
            # More detailed info about total expression
            "␂#{code}␃"
          end

        protected

          # @return [Boolean] false by default
          def operator?
            false
          end

        private

          # @param [Statement] a
          # @param [Statement] b
          # @return [Boolean]
          def mergeable?(a, b)
            a.operator? || b.operator?
          end

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
