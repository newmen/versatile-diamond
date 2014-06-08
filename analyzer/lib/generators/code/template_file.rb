module VersatileDiamond
  module Generators
    module Code

      # The base methods for templates generation
      module TemplateFile

        TEMPLATES_DIR = 'templates'

      private

        # Writes file to passed dir
        # @param [String] root_dir the out generation dir
        # @param [String] ext the extention of generation file
        def write_file(root_dir, ext)
          template = template_file(ext)
          dir_path = Pathname.new(root_dir) + additional_path
          FileUtils.mkdir_p(dir_path)

          full_path = dir_path + "#{file_name}.#{ext}"
          File.write(full_path, template.result(binding))
        end

        # Gets the path to template
        # @param [String] ext the extention of generation file
        # @return [Pathname] the full path to template
        def template_path(ext)
          Pathname.new(File.dirname(__FILE__)) +
            TEMPLATES_DIR + additional_path + "#{template_name}.#{ext}.erb"
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
      end

    end
  end
end
