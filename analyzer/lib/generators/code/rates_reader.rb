module VersatileDiamond
  module Generators
    module Code

      # Copies RatesReader class files and generates YAML config file
      class RatesReader
        extend Forwardable

        def_delegator :@generator, :reactions

        # Initializes by engine code generator
        # @param [EngineCode] generator of engine code
        def initialize(generator)
          @generator = generator
        end

        # Generates YAML config file
        # @param [String] root_dir the generation directory
        # @return [Array] common files of rates reader class
        # @override
        def generate(root_dir)
          ReactionsRatesYaml.new(self).generate(root_dir) +
            [CommonFile.new('reactions/rates_reader.h')] # cpp file also will be copied
        end
      end

    end
  end
end
