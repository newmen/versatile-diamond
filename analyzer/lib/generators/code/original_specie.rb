module VersatileDiamond
  module Generators
    module Code

      # Creates Original Specie class which is used when specie is simmetric
      class OriginalSpecie < CppClassWithGen
        extend SubSpecie
        include PolynameClass

        use_prefix 'original'

        # Initialize original specie class code generator
        # @param [EngineCode] generator see at #super same argument
        # @param [Specie] specie which is main specie class generator
        def initialize(generator, specie)
          super(generator)
          @specie = specie
          @_prefix = nil
        end

        # Gets the file name of current specie
        # @return [String] the file name
        # @override
        def file_name
          "#{prefix}_#{@specie.enum_name}".downcase
        end

        # Substitute base classes list for original specie template rendering
        # @return [Array] the array with base engine class name
        def base_classes
          [@specie.wrapped_base_class]
        end

        # Deligates all method calls to main specie class generator
        # @param [Symbol] method_name which was not found
        # @param [Array] args the arguments of missed method
        def method_missing(method_name, *args)
          @specie.respond_to?(method_name) ?
            @specie.public_send(method_name, *args) :
            super
        end

      private

        # Original specie class haven't find algorithms by default
        # @return [Boolean] false
        def render_find_algorithms?
          return false
        end

        # Gets the name of template file
        # @return [String] the name of template file
        # @override
        def template_name
          @specie.template_name
        end
      end

    end
  end
end
