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

        def to_s
          class_name
        end

        def inspect
          to_s
        end

      private

        # The list of common files which are used by current generating class
        # @return [Array] list with base class file path
        # @override
        def using_common_files
          common_base_class_files
        end

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

        # Translates concept lattices to correspond crystal atom iterators
        # @param [Set] lattices which translated to iterators
        # @return [Array] the list of code generators
        def translate_to_iterators(lattices)
          lattices.to_a.compact.map do |lattice|
            generator.lattice_class(lattice).iterator
          end
        end

        # Provides final string for using it in code template files
        # @return [String] the string for inheritance
        def public_inheritance_from_base_classes
          base_class_names.map { |class_name| "public #{class_name}" }.join(', ')
        end

        # Gets a list of code elements each of which will be included in header file
        # @return [Array] the array of header including objects
        def head_include_objects
          head_used_objects + used_iterators + common_base_class_files
        end

        # Provides common files which is base class for current instance
        # @return [Array] the common files for current instance
        def common_base_class_files
          [common_file(outer_base_name)]
        end

        # Gets the name of directory where will be stored result file
        # @return [String] the name of result directory
        def outer_dir_name
          outer_base_name.pluralize
        end

        # The additional path of current instance generation result
        # @return [Pathname] the directory when will be stored result of generation
        # @override
        def result_additional_path
          super + outer_dir_name
        end
      end

    end
  end
end
