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

          # @param [Statement]
          # @return [Statement]
          def +(other)
            OpCombine[self, other]
          end

          def to_s
            "␂#{code}␃"
          end

          def inspect
            # More detailed info about total expression
            "\n#{code}\n"
          end

        private

          # @param [Array] vars
          # @return [Array] list of using variables
          def using(vars)
            exprs.flat_map { |expr| expr.using(vars) }
          end

          # @param [String] str to which the semicolon will be added
          # @return [String] the string with code which ends with semicolon
          def wrap(str)
            "TAB_SPACES#{str};"
          end
        end

      end
    end
  end
end
