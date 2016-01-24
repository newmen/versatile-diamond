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
            :expr?, :var?, :const?, :scalar?, :type?, :op?, :tin?, :cond?, :assign?
          ].freeze

          class << self
            # @param [Array] exprs
            # @param [Hash] kwargs
            # @return [Statement]
            def [](*exprs, **kwargs)
              kwargs.empty? ? new(*exprs) : new(*exprs, **kwargs)
            end
          end

          # @param [Statement]
          # @return [Statement]
          def +(other)
            if concatable?(other)
              OpCombine[self, other]
            else
              msg = "Cannot concate #{self.inspect} with #{other.inspect}"
              raise ArgumentError, msg
            end
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
            # More detailed info about total expression
            "␂#{code}␃"
          end

        protected

          # @return [Boolean]
          def separated?
            (expr? && !const?) || cond? || assign?
          end

        private

          # @param [Statement] other
          # @return [Boolean]
          def concatable?(other)
            other.op? || (separated? && other.separated?)
          end

          # @param [String] str to which the prefix spaces (offset) will be added
          # @return [String]
          def shift(str)
            map_lines(str, &method(:prepend_offset))
          end

          # @param [String] str to which the semicolon will be added
          # @return [String]
          def wrap(str)
            map_lines(str) { |line| "#{prepend_offset(line)};" }
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
        end

      end
    end
  end
end
