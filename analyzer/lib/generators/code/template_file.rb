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
          File.write(out_path(root_dir, ext), template_file(ext).result(binding))
        end

        # Makes out directory if it does not exist. Gets the path to output directory
        # @param [String] root_dir see at #write_file same argument
        # @return [Pathname] the path to output directory
        def out_dir(root_dir)
          path = Pathname.new(root_dir) + additional_path
          FileUtils.mkdir_p(path)
          path
        end

        # Get full out path to result file
        # @param [String] root_dir see at #write_file same argument
        # @param [String] ext see at #write_file same argument
        # @return [Pathname] the path to output file
        def out_path(root_dir, ext)
          out_dir(root_dir) + "#{file_name}.#{ext}"
        end

        # Get the path to template dir where is stored file
        # @return [Pathname] the path to template dir
        def template_dir
          Pathname.new(File.dirname(__FILE__)) + TEMPLATES_DIR + additional_path
        end

        # Gets the path to template
        # @param [String] ext the extention of generation file
        # @return [Pathname] the full path to template
        def template_path(ext)
          template_dir + "#{template_name}.#{ext}.erb"
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
