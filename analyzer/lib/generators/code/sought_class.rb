module VersatileDiamond
  using Patches::RichString

  module Generators
    module Code

      # Provides logic for all reation generators
      # @abstract
      class SoughtClass < CppClassWithGen
        include PolynameClass

        PREF_METD_SEPS = [
          ['class', :classify, ''],
          ['enum', :upcase, '_'],
          ['file', :downcase, '_'],
        ].freeze

        # Provides classes list from which occur inheritance when template renders
        # @return [Array] the array of cpp class names
        # TODO: must be private
        def base_class_names
          [base_class_name] + iterator_class_names
        end

        # Gets outer template name of base class
        # @return [String] the outer base class name
        def outer_base_name
          outer_base_class_name.underscore
        end

      private

        # By default sought instance doesn't use lattice atom iterators
        # @return [Array] the empty array by default
        def used_iterators
          []
        end

        # Combines used iterators for using them as parent classes
        # @return [Array] the array that contain parent class names from which
        #   specie class instance will be inheritance in source code
        def iterator_class_names
          used_iterators.map(&:class_name)
        end

        # Provides final string for using it in code template files
        # @return [String] the string for inheritance
        def public_inheritance_from_base_classes
          base_class_names.map { |class_name| "public #{class_name}" }.join(', ')
        end

        # Provides common file which is base class for current instance
        # @return [CommonFile] the common file for current specie
        def common_base_class_file
          CommonFile.new("#{template_additional_path}/#{outer_base_name}.h")
        end

        # The additional path of current instance generation result
        # @return [Pathname] the directory when will be stored result of generation
        # @override
        def result_additional_path
          super + outer_base_name.pluralize
        end
      end

    end
  end
end
