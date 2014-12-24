module VersatileDiamond
  using Patches::RichString

  module Generators
    module Code

      # Provides methods at class level for some source file coping
      # Should extends class with TemplateFile mixin
      module SourceFileCopier
      private

        # Copy the file to result source dir
        # @param [String] root_dir the directory of generation results
        # @param [String] file_name the name of coping file
        def copy_file(root_dir, file_name)
          FileUtils.cp(src_file_path(file_name), dst_file_path(root_dir, file_name))
        end

        # Gets the source file path to passed file
        # @return [Pathname] the path to file
        def src_file_path(file_name)
          template_dir + file_name
        end

        # Gets the destination file path for passed file name
        # @param [String] root_dir the directory of generation results
        # @param [String] file_name the name of coping file
        # @return [Pathname] the path to result file
        def dst_file_path(root_dir, file_name)
          full_path = out_dir(CppClass.src_dir(root_dir)) + file_name
          full_path.dirname.mkpath
          full_path
        end
      end

    end
  end
end
