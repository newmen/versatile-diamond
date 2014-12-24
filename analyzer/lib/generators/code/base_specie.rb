module VersatileDiamond
  module Generators
    module Code

      # Provides logic for all specie generators
      # @abstract
      class BaseSpecie < SoughtClass
      private

        # The additional path for current instance
        # @return [String] the additional directories path
        # @override
        def template_additional_path
          'species'
        end
      end

    end
  end
end
