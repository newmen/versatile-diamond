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

          PREDICATES = [
            :expr?, :const?, :var?,
            :scalar?, :type?,
            :op?, :tin?, :cond?, :assign?
          ].freeze

          class << self
            # @param [Array] exprs
            # @param [Hash] kwargs
            # @return [Statement]
            def [](*exprs, **kwargs)
              kwargs.empty? ? new(*exprs) : new(*exprs, **kwargs)
            end

            # @raise [ArgumentError]
            def arg_err!(msg)
              raise ArgumentError, msg
            end
          end

          # @param [Statement]
          # @return [Statement]
          def +(other)
            OpCombine[self, other]
          end

          PREDICATES.each do |name|
            # Checks that current statement is #{name}
            # @return [Boolean] false by default
            define_method(name) { false }
          end

          def to_s
            "\n#{code}\n"
          end

          def inspect
            # TODO: Add more detailed info about total expression
            "␂#{code}␃"
          end

        private

          def_delegator Statement, :arg_err!

          # @param [String] str to which the prefix spaces (offset) will be added
          # @return [String]
          def shift(str)
            map_lines(str, &method(:prepend_offset))
          end

          # @param [String] str to which the semicolon will be added
          # @return [String]
          def wrap(str)
            map_lines(str, &method(:terminated_offset))
          end

          # @param [String] str
          # @yield [String]
          # @return [Array]
          def map_lines(str, &block)
            str.split("\n").map(&block).join("\n")
          end

          # @param [String] str
          # @return [String]
          def prepend_offset(str)
            "#{TAB_SPACES}#{str}"
          end

          # @param [String] str
          # @return [String]
          def terminated_offset(str)
            "#{prepend_offset(str)};"
          end
        end

      end
    end
  end
end
