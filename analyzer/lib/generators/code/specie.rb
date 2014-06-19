module VersatileDiamond
  using Patches::RichString

  module Generators
    module Code

      # Creates Specie class
      class Specie < CppClassWithGen
        include PolynameClass

        # Initialize specie code generator
        # @param [EngineCode] generator see at #super same argument
        # @param [Organizers::DependentSpec] spec source file for which will be
        #   generated
        def initialize(generator, spec)
          super(generator)
          @spec = spec
        end

        # Makes class name for current specie
        # @return [String] the result class name
        # @example generating name
        #   'hydrogen(h: *)' => 'HydrogenHs'
        def class_name
          @spec.name.to_s.capitalize.
            gsub('*', 's').
            gsub(/(\w+):/) { |label| label.upcase }.
            gsub(/[\(\) :]/, '')
        end
      end

    end
  end
end