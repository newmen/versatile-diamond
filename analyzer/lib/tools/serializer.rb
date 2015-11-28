module VersatileDiamond
  module Tools

    # Provides serialize options for analysis result data and store marshaled
    # object to file. Also provides abilities to restore object from file.
    module Serializer
      VD_CONFIG_EXT = '.rb'

      class << self
        # Initializes serializer
        # @param [String] dump_dir the directory where dump files will be stored
        def init!(dump_dir)
          FileUtils.mkdir_p(dump_dir) unless Dir.exist?(dump_dir)
          @dump_dir = dump_dir
        end

        # Loads some data by config file path and suffix
        # @param [String] config_path to config file path
        # @option [String] :suffix to result file name
        # @return [Object] the loaded object or nil
        def load(config_path, suffix: nil)
          # проверяем, что есть файл с суммой
          #   есть: сверяем сумму
          #     она же: грузим дамп

          if checksum(config_path) == stored_checksum(config_path)
            Marshal.load(read_dump(config_path, suffix))
          end
        end

        # Saves data to files the names of which will be obtained by config file path
        # and suffix
        #
        # @param [String] config_path to config file path
        # @option [String] :suffix to result file name
        # @return [Object] the loaded object or nil
        def save(config_path, data, suffix: nil)
          save_checksum(config_path) unless suffix
          save_dump(config_path, Marshal.dump(data), suffix)
        end

      private

        # Gets the md5 hash of file
        # @param [String] path to checksuming file
        # @return [String] the md5 hash
        def checksum(path)
          Digest::MD5.file(path).hexdigest
        end

        # Gets stored checksum for config file
        # @param [String] path to config file
        def stored_checksum(path)
          chpath = checksum_path(path)
          File.exist?(chpath) && File.read(chpath)
        end

        # Reads correspond dump file
        # @param [String] path to config file
        # @param [String] suffix of result file
        def read_dump(path, suffix)
          File.read(dump_path(path, suffix))
        end

        # Calculates the checksum of file
        # @param [String] path to config file
        def checksum_path(path)
          path_to(:md5, path)
        end

        # Gets the path to dump file
        # @param [String] path to file where stored dump
        # @param [String] suffix of result file
        def dump_path(path, suffix)
          path_to(:dump, path, suffix: suffix)
        end

        # Gets the path to dump directory to some of serialable file
        # @param [String] ext the extention of storable file
        # @param [String] path to file of config
        # @option [String] :suffix to result file name
        # @return [Pathname] the path to serialable file
        def path_to(ext, path, suffix: nil)
          suffix = "-#{suffix}" if suffix
          filename = File.basename(path, VD_CONFIG_EXT)
          Pathname.new(@dump_dir) + "#{filename}#{suffix}.#{ext}"
        end

        # Saves checksum of config file to correspond file
        # @param [String] path to file of config
        def save_checksum(path)
          File.write(checksum_path(path), checksum(path))
        end

        # Saves dump
        # @param [String] path to config file
        # @param [String] dump the string of dumped object
        # @param [String] suffix of result file
        def save_dump(path, dump, suffix)
          File.write(dump_path(path, suffix), dump)
        end
      end
    end

  end
end
