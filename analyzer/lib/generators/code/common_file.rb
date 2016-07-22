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
          unless exist?(path_to_common_file)
            raise "Undefined common file '#{path_to_common_file}'"
          end

          @path = Pathname.new(File.dirname(path_to_common_file))
          @ext = File.extname(path_to_common_file)
          @file_name = File.basename(path_to_common_file, @ext)
        end

        # Gets the full path to common header file
        # @raise [SystemError] if current common file isn't cpp header file
        # @return [Pathname] the full path to common header file
        def full_file_path
          raise "Current common file isn't header file" unless @ext == '.h'
          (@path + @file_name).sub_ext(@ext)
        end

      private

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
      end

    end
  end
end
