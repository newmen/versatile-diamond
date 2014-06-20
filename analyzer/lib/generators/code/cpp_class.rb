module VersatileDiamond
  module Generators
    module Code

      # The base class for cpp class templates generation
      # Provides methods for generates c++ source files through erb templates
      # @abstract
      class CppClass
        include TemplateFile

        SRC_DIR_NAME = 'src'

        class << self
          # Extends root dir path to source dir path
          # @param [String] root_dir the generation output directory
          # @return [String] the path to source code directory
          def src_dir(root_dir)
            (Pathname.new(root_dir) + SRC_DIR_NAME).to_s
          end
        end

        # Generates .h and .cpp files for current instance
        # @param [String] root_dir the generation output directory
        def generate(root_dir)
          sdr = self.class.src_dir(root_dir)
          write_file(sdr, 'h')
          write_file(sdr, 'cpp') if File.exist?(template_path('cpp'))
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
