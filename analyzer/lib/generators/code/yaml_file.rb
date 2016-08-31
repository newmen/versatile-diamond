module VersatileDiamond
  module Generators
    module Code

      # The base class for yaml templates generation
      # Provides methods for generates yaml config files through erb templates
      # @abstract
      class YamlFile
        include TemplateFile

        # Initialize YAML file generator
        # @param [Object] code_class the instance class file generator
        def initialize(code_class)
          @code_class = code_class
        end

        # Generates .h and .cpp files for current instance
        # @param [String] root_dir the generation directory
        # @return [Array] yaml file no any dependencs from another file by default
        def generate(root_dir)
          write_file(root_dir, 'yml')
          []
        end

      private

        attr_reader :code_class

        # Yaml config files located in configs directory
        # @return [String] the config directory name
        def template_additional_path
          'configs'
        end
      end

    end
  end
end
