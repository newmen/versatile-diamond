module VersatileDiamond
  module Generators
    module Code

      # Creates Symmetric Specie class which is used when specie is simmetric
      class SymmetricSpecie < CppClassWithGen
        include EnumerableOutFile
        extend SubSpecie

        use_prefix 'symmetric'

        # Initialize original specie class code generator
        # @param [EngineCode] generator see at #super same argument
        # @param [Specie] original specie which is main original specie_class generator
        def initialize(generator, original_specie, indexes)
          super(generator)
          @specie = original_specie
          @_prefix = nil
        end

        # Gets the enum name of current specie
        # @return [String] the enum name
        def enum_name
          "#{prefix.upcase}_#{@specie.enum_name}"
        end


      private

      end

    end
  end
end
