module VersatileDiamond
  module Generators
    module Code

      # The base class for cpp class templates generation
      # Provides methods for generates c++ source files through erb templates
      # @abstract
      class CppClass

        TEMPLATES_DIR = 'templates/'

        # Initializes by engine code generator
        # @param [EngineCode] generator of engine code
        def initialize(generator)
          @generator = generator
        end

        # Generates .h and .cpp files for current instance
        # @param [String] root_dir the generation directory
        def generate(root_dir)
          FileUtils.mkdir_p(root_dir)
          write_file(root_dir, 'h')
          write_file(root_dir, 'cpp') if File.exist?(template_path('cpp'))
        end

      private

        # Writes file to passed dir
        # @param [String] root_dir the out generation dir
        # @param [String] ext the extention of generation file
        def write_file(root_dir, ext)
          template = template_file(ext)
          dir_path = Pathname.new(root_dir) + additional_path
          full_path = dir_path + "#{file_name}.#{ext}"
          File.write(full_path, template.result(binding))
        end

        # Gets the path to template
        # @param [String] ext the extention of generation file
        # @return [Pathname] the full path to template
        def template_path(ext)
          Pathname.new(File.dirname(__FILE__)) +
            TEMPLATES_DIR + "#{template_name}.#{ext}.erb"
        end

        # Gets the template as erb data
        # @param [String] ext the extention of generation file
        # @return [ERB] the template as erb data
        def template_file(ext)
          ERB.new(File.read(template_path(ext)))
        end

        # Gets the name of template file without extention
        # @return [String] the underscored name of current class instance
        def template_name
          self.class.to_s.split('::').last.underscore
        end

        # The additional path for current instance
        # @return [String] the additional directories path
        def additional_path
          '.'
        end
      end

    end
  end
end
