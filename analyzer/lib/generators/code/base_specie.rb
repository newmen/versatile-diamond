module VersatileDiamond
  module Generators
    module Code

      # Extends cpp class with generator
      # @abstract
      class BaseSpecie < CppClassWithGen
        include PolynameClass

        PREF_METD_SEPS = [
          ['class', :classify, ''],
          ['enum', :upcase, '_'],
          ['file', :downcase, '_'],
        ].freeze

      private

        # Provides common file which is base class for current instance
        # @return [CommonFile] the common file for current specie
        def common_base_class_file
          CommonFile.new("species/#{outer_base_file}.h")
        end

        # The additional path for current instance
        # @return [String] the additional directories path
        # @override
        def template_additional_path
          'species'
        end

        # The additional path of current instance generation result
        # @return [Pathname] the directory when will be stored result of generation
        # @override
        def result_additional_path
          super + outer_base_file
        end
      end

    end
  end
end
