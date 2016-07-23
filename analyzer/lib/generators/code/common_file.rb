module VersatileDiamond
  module Generators
    module Code

      # Wraps common files
      class CommonFile

        COMMON_FILES_DIR = 'common_files'.freeze

        # Initialize common file by path to it
        # @param [String] path_to_common_file
        # @raise [SystemError] if file by passed path doesn't exist
        def initialize(path_to_common_file)
          @path = Pathname.new(File.dirname(path_to_common_file))
          @ext = File.extname(path_to_common_file)
          @file_name = File.basename(path_to_common_file, @ext)
        end

        # @param [CommonFile] other
        # @return [Boolean]
        def ==(other)
          full_file_path == other.full_file_path
        end
        alias :eql? :==

        # @return [Integer]
        def hash
          full_file_path.to_s.hash
        end

        # Gets the full path to common header file
        # @raise [SystemError] if current common file isn't cpp header file
        # @return [Pathname] the full path to common header file
        def full_file_path
          result = path_with(@ext)
          if exist?(result)
            result
          else
            raise "Undefined common file '#{result}'"
          end
        end

        # Copies the target self file to out directory
        # @param [String] out_path
        def copy_to(out_path)
          copy_file(full_file_path, out_path)
          if @ext == '.h'
            body_file_path = path_with('.cpp')
            copy_file(body_file_path, out_path) if exist?(body_file_path)
          end
        end

      private

        # Copies file to out directory
        # @param [Pathname] file_path
        # @param [String] out_path
        def copy_file(file_path, out_path)
          FileUtils.cp(common_files_dir + file_path, destination_dir(out_path))
        end

        # Gets path with passed extension
        # @param [String] ext
        # @return [Pathname]
        def path_with(ext)
          (@path + @file_name).sub_ext(ext)
        end

        # Checks that file by passed path is available
        # @param [String] path_to_common_file
        # @return [Boolean] is available or not
        def exist?(path_to_common_file)
          File.exist?(common_files_dir + path_to_common_file)
        end

        # Get the path to dir where are stored all common files
        # @return [Pathname] the path to common files dir
        def common_files_dir
          Pathname.new(File.dirname(__FILE__)) + COMMON_FILES_DIR
        end

        # @param [String] out_path
        # @return [Pathname] the path to output directory
        def destination_dir(out_path)
          Pathname.new(CppClass.src_dir(out_path)) + @path
        end
      end

    end
  end
end
