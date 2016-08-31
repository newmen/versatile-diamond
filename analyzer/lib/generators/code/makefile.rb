module VersatileDiamond
  using Patches::RichString

  module Generators
    module Code

      # Generates the Makefile for generating code
      class Makefile
        include TemplateFile

        ENGINE_SOURCE_DIR_PATH = '../../../../engine'.freeze
        SIMULATION_NAME = 'simulate'.freeze

        # Makes some required preparation
        def initialize
          # The class scope variable is required cause relative_engine_dir_path should
          # be calculated under file generation
          @root_dir = nil
        end

        # Generates YAML config file
        # @param [String] root_dir the generation directory
        # @return [Array] the empty array
        def generate(root_dir)
          @root_dir = root_dir.freeze # single place of instance variable assignation
          write_file(@root_dir, '')
          []
        end

      private

        # @return [Pathname] the path to engine source dir
        def engine_source_dir
          current_dir + ENGINE_SOURCE_DIR_PATH
        end

        # @return [String]
        def relative_engine_dir_path
          result_dir = Pathname.new(@root_dir).realpath
          engine_source_dir.relative_path_from(result_dir).to_s
        end

        # @return [String]
        def simulation_name
          SIMULATION_NAME
        end

        # @return [String]
        def template_name
          super.classify
        end
        alias :file_name :template_name

        # Yaml config files located in configs directory
        # @return [String] the config directory name
        def template_additional_path
          '.'
        end
      end

    end
  end
end
