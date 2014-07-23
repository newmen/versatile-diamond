module VersatileDiamond
  module Generators
    module Code

      # Creates Symmetric Specie class which is used when specie is simmetric
      # @abstract
      class SymmetricSpecie < BaseSpecie
        extend SubSpecie

        use_prefix 'symmetric'

        # Initialize original specie class code generator
        # @param [EngineCode] generator see at #super same argument
        # @param [Specie] original specie which is main original specie_class generator
        def initialize(generator, original_specie, from_index, to_index)
          super(generator)
          @specie = original_specie
          @from_index, @to_index = from_index, to_index
          @_prefix = nil
        end

        # Gets the same template file name for each derived classes
        # @return [String] the name of template file
        # @override
        def template_name
          'symmetric_specie'
        end

      private

        # Gets the main specie to which all undefined methods are redirects
        # @return [Specie] the main original specie
        def main_specie
          @specie.main_specie
        end

        # Gets the base class of cpp class of symmetric specie
        # @return [String] the name of base class
        def base_class_name
          "#{wrapper_class}<Empty<#{enum_name}>, #{@from_index}, #{@to_index}>"
        end

        # Gets class name of original specie
        # @return [String] the original specie class name
        def original_class_name
          @specie.class_name
        end

        # Gets the path to original specie header file without extension
        # @return [String] the path to original specie header file
        def original_file_path
          "#{@specie.outer_base_file}/#{@specie.file_name}"
        end

        # Gets the name to outer class header file without extension
        # @return [String] the name of outer class header file
        def outer_base_file
          'empty'
        end
      end

    end
  end
end
