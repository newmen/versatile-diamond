module VersatileDiamond
  module Generators
    module Code

      # The base class for cpp class templates generation
      # Provides methods for generates c++ source files through erb templates
      # @abstract
      class CppClass < Base
        include TemplateFile

        # Initializes by engine code generator
        # @param [EngineCode] generator of engine code
        def initialize(generator)
          @generator = generator
        end

        # Generates .h and .cpp files for current instance
        # @param [String] root_dir the generation directory
        def generate(root_dir)
          write_file(root_dir, 'h')
          write_file(root_dir, 'cpp') if File.exist?(template_path('cpp'))
        end

      private

        # The additional path for current instance
        # @return [String] the additional directories path
        def additional_path
          '.'
        end
      end

    end
  end
end
