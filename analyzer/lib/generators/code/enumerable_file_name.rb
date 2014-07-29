module VersatileDiamond
  module Generators
    module Code

      # Provides methods which targeted to #enum_name of some generating entity
      module EnumerableFileName

        # Makes correct file name
        # @return [String] the file name for generation result
        # @override
        def file_name
          enum_name.downcase
        end
      end

    end
  end
end
