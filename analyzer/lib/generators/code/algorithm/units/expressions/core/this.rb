module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Describes chunks aggregator array variable
        class This < Variable

          NAME = 'this'.freeze

          class << self
            # @param [Object] instance
            # @param [String] class_name
            # @return [This]
            def [](instance, class_name)
              super(instance, ObjectType[class_name].ptr, NAME)
            end
          end
        end

      end
    end
  end
end
