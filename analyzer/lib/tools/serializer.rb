require 'pathname'
require 'fileutils'

module VersatileDiamond
  module Tools

    # Provides serialize options for analysis result data and store marshaled
    # object to file. Also provides abilities to restore object from file.
    module Serializer
      DUMP_DIR = 'cache/'
      VD_CONFIG_EXT = '.rb'

      class << self
        def load(config_path)
          # проверяем, что есть файл с суммой
          #   есть: сверяем сумму
          #     она же: грузим дамп

          if checksum(config_path) == stored_checksum(config_path)
            Marshal.load(read_dump(config_path))
          end
        end

        def save(config_path, data)
          FileUtils.mkdir_p(DUMP_DIR) unless Dir.exist?(DUMP_DIR)

          save_checksum(config_path)
          save_dump(config_path, Marshal.dump(data))
        end

      private

        # Gets the md5 hash of file
        # @param [String] path to checksuming file
        # @return [String] the md5 hash
        def checksum(path)
          Digest::MD5.file(path).hexdigest
        end

        def stored_checksum(path)
          chpath = checksum_path(path)
          File.exist?(chpath) && File.read(chpath)
        end

        def read_dump(path)
          File.read(dump_path(path))
        end

        def checksum_path(path)
          path_to(:md5, path)
        end

        def dump_path(path)
          path_to(:dump, path)
        end

        def path_to(ext, path)
          filename = File.basename(path, VD_CONFIG_EXT)
          Pathname.new(DUMP_DIR) + "#{filename}.#{ext}"
        end

        def save_checksum(path)
          File.write(checksum_path(path), checksum(path))
        end

        def save_dump(path, dump)
          File.write(dump_path(path), dump)
        end
      end
    end

  end
end
