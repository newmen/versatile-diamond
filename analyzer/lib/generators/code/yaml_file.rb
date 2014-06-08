module VersatileDiamond
  module Generators
    module Code

      # The base class for yaml templates generation
      # Provides methods for generates yaml config files through erb templates
      # @abstract
      class YamlFile
        include TemplateFile

        # Generates .h and .cpp files for current instance
        # @param [String] root_dir the generation directory
        def generate(root_dir)
          write_file(root_dir, 'yml')
        end

      private

        # Yaml config files located in configs directory
        # @return [String] the config directory name
        # @override
        def additional_path
          'configs'
        end
      end

    end
  end
end
