module VersatileDiamond
  module Generators
    module Code

      # Extends cpp class with generator
      # @abstract
      class BaseSpecie < CppClassWithGen
        include PartialRenderer
        include PolynameClass
        include EnumerableFileName # must be included after PolynameClass

        PREF_METD_SEPS = [
          ['class', :classify, ''],
          ['enum', :upcase, '_']
        ].freeze

        # Gets full path to specie header file
        # @return [String] the path to specie header file
        def full_file_path
          "#{outer_base_file}/#{file_name}"
        end

      private

        # Makes output directory path where generating file will be created
        # @param [String] root_dir see at #super same argument
        # @return [Pathname] the path to output directory
        # @override
        def out_dir_path(root_dir)
          super + outer_base_file
        end

        # The additional path for current instance
        # @return [String] the additional directories path
        # @override
        def additional_path
          'species'
        end
      end

    end
  end
end
