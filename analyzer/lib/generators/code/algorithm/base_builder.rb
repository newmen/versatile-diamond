module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contain base logic for building find algorithms
        # @abstract
        class BaseBuilder
          include ProcsReducer

          # Inits builder by main engine code generator
          # @param [EngineCode] generator the major engine code generator
          def initialize(generator)
            @generator = generator
          end

        private

          attr_reader :generator

        end

      end
    end
  end
end
