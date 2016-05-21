module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Wraps the statement to squire brakets
        class OpSquireBks < OpBrakets
          class << self
            # @param [Expression] expr
            # @return [OpSquireBks]
            def [](expr)
              if valid?(expr)
                super
              else
                arg_err!("Wrong argument of squire brakets #{expr.inspect}")
              end
            end
          end

        private

          # @return [Symbol]
          def mark
            :[]
          end
        end

      end
    end
  end
end
