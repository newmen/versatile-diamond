module VersatileDiamond

  class Gas < Phase
    extend Forwardable
    include Singleton

    def initialize
      super
      @specs = []
      @concentrations = {}
    end

    def_delegator :@specs, :include?

    def spec_class
      GasSpec
    end

    def spec(name)
      @specs << super
    end

    def concentration(specified_spec_str, value, dimension = nil)
      specific_spec = SpecificSpec.new(specified_spec_str)
      unless specific_spec.is_gas? # TODO: strongly connected componente!
        syntax_error('.undefined_spec', name: specific_spec)
      end

      @concentrations[specific_spec] =
        Dimensions.convert_concentration(value, dimension)
    end

    def [](specific_spec)
      pair = @concentrations.find { |k, v| k.same?(specific_spec) }
      pair ? pair.last : syntax_error('.undefined_spec', name: specific_spec)
    end
  end

end
