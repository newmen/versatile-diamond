module VersatileDiamond
  using Patches::RichString

  module Generators
    module Code

      # Provides methods at class level for some source file coping
      # Should extends some class
      module SourceFileCopier
      private

        # Describes methods for coping c++ source files
        def copy_source(*names)
          names.each do |name|
            name_method = :"#{name}_name"
            file_name_method = :"#{name}_file_name"

            # The class name of lattice #{name} code instance
            # @return [String] the class name of used #{name}
            define_method(:"#{name}_class_name") do
              send(name_method).classify
            end

            # The file name of lattice #{name} code instance
            # @return [String] the file name of used #{name}
            define_method(file_name_method) do
              "#{send(name_method)}.h"
            end

            # The name of lattice #{name} code instance
            # @return [String] the #{name} underscored instance name
            define_method(name_method) do
              "#{class_name.underscore}_#{name}"
            end
            private name_method

            # The source file path to #{name} header file
            # @return [Pathname] the path to source #{name} file
            snfp = define_method(:"src_#{name}_file_path") do
              template_dir + send(file_name_method)
            end
            private snfp

            # The destination file path to #{name} header file
            # @param [String] root_dir the directory of generation results
            # @return [Pathname] the path to result #{name} file
            dnfp = define_method(:"dst_#{name}_file_path") do |root_dir|
              out_dir(CppClass.src_dir(root_dir)) + send(file_name_method)
            end
            private dnfp

            # Copy the #{name} header file to result source dir
            # @param [String] root_dir the directory of generation results
            cnfp = define_method(:"cp_#{name}_file_path") do |root_dir|
              FileUtils.cp(
                send(:"src_#{name}_file_path"),
                send(:"dst_#{name}_file_path", root_dir))
            end
            private cnfp
          end
        end
      end

    end
  end
end
