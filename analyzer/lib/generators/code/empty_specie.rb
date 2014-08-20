module VersatileDiamond
  module Generators
    module Code

      # Creates Symmetric Specie class which is used when specie is simmetric
      # @abstract
      class EmptySpecie < BaseSpecie
        extend SubSpecie

        use_prefix 'symmetric'

        # Initialize original specie class code generator
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

        # Gets the class name of current specie code instance
        # @return [String] the class name of specie code instance
        alias_method :super_class_name, :class_name
        def class_name
          "#{super_class_name}#{@suffix}"
        end

        # Gets the base class for cpp class of symmetric specie
        # @return [String] the name of base class
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

      private

        # Gets the original specie of target specie
        # @return [OriginalSpecie] the original specie which is wrapping
        def original_specie
          target_specie.original
        end
      end

    end
  end
end