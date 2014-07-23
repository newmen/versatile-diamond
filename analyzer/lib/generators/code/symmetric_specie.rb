module VersatileDiamond
  module Generators
    module Code

      # Creates Symmetric Specie class which is used when specie is simmetric
      class SymmetricSpecie < BaseSpecie
        extend SubSpecie

        use_prefix 'symmetric'

        # Initialize original specie class code generator
        # @param [EngineCode] generator see at #super same argument
        # @param [Specie] original specie which is main original specie_class generator
        def initialize(generator, original_specie)
          super(generator)
          @specie = original_specie
          @_prefix = nil
        end

        # Gets the main specie to which all undefined methods are redirects
        # @return [Specie] the main original specie
        # TODO: should be private
        def main_specie
          @specie.main_specie
        end

        # Gets the base class of cpp class of symmetric specie
        # @return [String] the name of base class
        # TODO: should be private
        def base_class_name
          "Empty<#{enum_name}>"
        end

      private

      end

    end
  end
end
