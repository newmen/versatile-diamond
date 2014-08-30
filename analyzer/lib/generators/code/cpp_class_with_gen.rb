module VersatileDiamond
  module Generators
    module Code

      # Instance of class have link to generator
      # @abstract
      class CppClassWithGen < CppClass

        # Initializes by engine code generator
        # @param [EngineCode] generator of engine code
        def initialize(generator)
          @generator = generator
        end

      private

        attr_reader :generator

      end

    end
  end
end

