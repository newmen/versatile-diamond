module VersatileDiamond
  module Generators
    module Code

      # The base class for cpp class templates generation
      # Provides methods for generates c++ source files through erb templates
      # @abstract
      class CppClass
        include TemplateFile
        include PartialRenderer

        SRC_DIR_NAME = 'src'.freeze

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

        # Gets default name of file which will be generated
        # @return [String] the default name of result file without extention
        def file_name
          template_name
        end

        # Gets full path to class header file
        # @return [String] the path to class header file
        def full_file_path
          (Pathname.new(result_additional_path) + file_name).sub_ext('.h')
        end

        %w(head body).each do |type|
          # Provides #{type}_includes helper which could be used for rendering the
          # list of includes. Requires #{type}_include_objects method definition.
          #
          # @return [String] the cpp code with include lines
          define_method(:"#{type}_includes") do
            objects = send(:"#{type}_include_objects")
            pathes = collect_file_pathes(objects)

            levels_num = count_levels(template_additional_path)
            partial_name = ('../' * levels_num) + 'includes'
            render_partial(partial_name, locals: { include_pathes: pathes })
          end
        end

      private

        # Collects pathes to files which will be included when generation do
        # @param [Array] others objects which full pathes will be normalized by current
        # @return [Array] the sorted relative pathes to other objects header files
        #   (without extenstion of it header file)
        def collect_file_pathes(others)
          curr_path = full_file_path
          pathes = others.map do |o|
            o.full_file_path.relative_path_from(curr_path + '..')
          end
          pathes.sort
        end

        # Counts number of nested directories in passed path
        # @param [String] path which will be analyzed
        # @return [Integer] the number of directories
        def count_levels(path)
          parent_path = Pathname.new(path)
          stop_point = Pathname.new('.')
          counter = 0
          until parent_path == stop_point
            parent_path = parent_path.parent
            counter += 1
          end
          counter
        end

        # The additional path to template of current instance
        # @return [String] the directory when stored template of current class
        def template_additional_path
          '.'
        end
      end

    end
  end
end
