module VersatileDiamond
  module Generators
    module Code

      # Creates Symmetric Specie class which is used when specie is simmetric
      # @abstract
      class EmptySpecie < BaseSpecie
        extend SubSpecie

        use_prefix 'symmetric'

        # Initialize empty specie class code generator
        # @param [EngineCode] generator see at #super same argument
        # @param [BaseSpecie] specie which is wrapped specie class generator
        def initialize(generator, specie)
          super(generator)
          @specie = specie
          @suffix = nil # by default each specie has only one symmetric analog
          @_prefix = nil
        end

        # Sets the suffix of current symmetric instance
        # @param [Integer] suffix index of symmetric specie
        def set_suffix(suffix)
          @suffix = suffix
        end

        # Gets the template file name
        # @return [String] the template file name
        def template_name
          'empty_specie' # because current class is abstract
        end

        %w(class file).each do |name|
          method_name = :"#{name}_name"
          super_method_name = :"super_#{method_name}"
          # Gets the #{name} name of current specie code instance
          # @return [String] the #{name} name of specie code instance
          alias_method super_method_name, method_name
          define_method(method_name) do
            "#{send(super_method_name)}#{@suffix}"
          end
        end

        # Delegates getting enum name to major specie code generator
        # @return [String] the enum name which will be used in code templates
        def enum_name
          target_specie.enum_name
        end

        # Gets the base class for cpp class of symmetric specie
        # @return [String] the full name of base class
        def base_class_name
          wbcn = @specie == original_specie ?
            "Empty<#{enum_name}>" : @specie.base_class_name

          add_args = additional_template_args.map { |arg| ", #{arg}" }.join
          "#{wrapper_class_name}<#{wbcn}#{add_args}>"
        end

        # Gets class name of original specie
        # @return [String] the original specie class name
        def original_class_name
          original_specie.class_name
        end

        # Gets the path to original specie header file without extension
        # @return [String] the path to original specie header file
        def original_file_path
          original_specie.full_file_path
        end

        # Gets the name to outer class header file without extension
        # @return [String] the name of outer class header file
        def outer_base_file
          'empty'
        end

        # The decorated printable name of major specie
        # @return [String] the printable name of specie with prefix
        def print_name
          "#{prefix}_#{target_specie.print_name}"
        end

      protected

        # Gets the main specie to which all undefined methods are redirects
        # @return [Specie] the main original specie
        def target_specie
          @specie.target_specie
        end

        # Gets the original specie of target specie
        # @return [OriginalSpecie] the original specie which is wrapping
        def original_specie
          target_specie.original
        end

        # Gets the list of objects which headers should be included in header file
        # @return [Array] the list of including objects
        # @override
        def head_include_objects
          [original_specie, common_base_class_file]
        end
      end

    end
  end
end
