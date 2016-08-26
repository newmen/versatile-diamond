module VersatileDiamond
  module Generators
    module Code

      # Generates the YAML configuration file with run options
      class Config

        # Initializes by engine code generator
        # @param [EngineCode] generator of engine code
        def initialize(generator)
          @generator = generator
        end

        # @return [Array]
        def atom_properties
          @generator.classifier.props
        end

        # Generates YAML config file
        # @param [String] root_dir the generation directory
        # @return [Array] common files of rates reader class
        # @override
        def generate(root_dir)
          RunYaml.new(self).generate(root_dir)
        end
      end

    end
  end
end
