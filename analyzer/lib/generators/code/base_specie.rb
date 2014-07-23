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
      end

    end
  end
end
