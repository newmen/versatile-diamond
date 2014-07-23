module VersatileDiamond
  module Generators
    module Code

      # Extends cpp class with generator
      # @abstract
      class BaseSpecie < CppClassWithGen
        include PolynameClass
        include EnumerableOutFile # should be after PolynameClass

        PREF_METD_SEPS = [
          ['class', :classify, ''],
          ['enum', :upcase, '_']
        ].freeze

      private

        # Makes output directory path where generating file will be created
        # @param [String] root_dir see at #super same argument
        # @return [Pathname] the path to output directory
        # @override
        def out_dir_path(root_dir)
          super + outer_base_file
        end
      end

    end
  end
end
