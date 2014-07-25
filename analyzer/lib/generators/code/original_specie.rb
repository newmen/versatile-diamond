module VersatileDiamond
  module Generators
    module Code

      # Creates Original Specie class which is used when specie is simmetric
      class OriginalSpecie < BaseSpecie
        extend TotalDelegator
        extend SubSpecie

        use_prefix 'original'
        deligate_to :@specie

        # Initialize original specie class code generator
        # @param [EngineCode] generator see at #super same argument
        # @param [Specie] specie which is main specie class generator
        def initialize(generator, specie)
          super(generator)
          @specie = specie
          @_prefix = nil
        end

        # Doesn't be automaticaly deligated because current instance already
        # have #template_name method
        undef :template_name

        # Gets the main specie to which all undefined methods are redirects
        # @return [Specie] the main original specie
        def target_specie
          @specie
        end

        # Substitute base classes list for original specie template rendering
        # @return [Array] the array with base engine class name
        def base_classes
          [target_specie.wrapped_base_class_name]
        end

      private

        # Original specie class haven't find algorithms by default
        # @return [Boolean] false
        def render_find_algorithms?
          return false
        end
      end

    end
  end
end
