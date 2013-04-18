class Gas < Phase
  def initialize
    super
    @specs = []
    @concentrations = {}
  end

  def spec_class
    GasSpec
  end

  def spec(name)
    @specs << super
  end

  def concentration(specified_spec_str, value, dimension = nil)
    specific_spec = SpecificSpec[specified_spec_str]
    syntax_error('.undefined_spec', name: name) unless @specs.include?(specific_spec.spec)
    @concentrations[specific_spec] = Dimensions.convert_concentration(value, dimension)
  end
end
