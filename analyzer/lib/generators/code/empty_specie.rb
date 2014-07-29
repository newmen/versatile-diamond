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
          @index = counter.next_index(self)

          @_prefix = nil
        end

        # Gets the key which will be used by counter for enumerate all analogies
        # symmetric species
        #
        # @return [Symbol] unique key for count analogies symmetric specie
        def counter_key
          target_specie.spec.name
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
          super_result = super_class_name
          counter.many_symmetrics?(self) ? "#{super_result}#{@index}" : super_result
        end

        # Gets the base class for cpp class of symmetric specie
        # @return [String] the name of base class
        def base_class_name
          wbcn = @specie == original_specie ?
            @specie.base_class_name : "Empty<#{enum_name}>"

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

      private

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

        # Gets the empty species counter for get an index or checks that has many
        # empty species
        #
        # @return [EmptySpeciesCounter] the counter of empty species
        def counter
          @generator.empties_counter
        end
      end

    end
  end
end
