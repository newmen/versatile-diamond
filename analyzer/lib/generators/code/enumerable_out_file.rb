module VersatileDiamond
  module Generators
    module Code

      # Provides methods which targeted to #enum_name of some generating entity
      module EnumerableOutFile

        # Gets the output file name for current generation
        # @return [String] the file name
        # @override
        def file_name
          enum_name.downcase
        end
      end

    end
  end
end
