module VersatileDiamond
  module Generators
    module Code

      # Creates parents swapped symmetric specie
      class ParentProxySpecie < EmptySpecie

        # Initialize parent proxy class code generator
        # @param [EngineCode] generator see at #super same argument
        # @param [OriginalSpecie] specie see at #super same argument
        # @param [EmptySpecie] deep_empty the empty specie to which proxy will be
        def initialize(generator, specie, deep_empty)
          super(generator, specie)
          @deep_empty = deep_empty
        end

        # Gets the base class which not directly dependent from Empty cpp class
        # @return [String] the full name of base class
        # @override
        def base_class_name
          args = [
            @deep_empty.original_specie.class_name,
            @deep_empty.class_name,
            enum_name
          ]

          "#{wrapper_class_name}<#{args.join(', ')}>"
        end

      private

        # Defines wrapper class name
        # @return [String] the engine wrapper class name
        def wrapper_class_name
          'ParentProxy'
        end
      end

    end
  end
end
