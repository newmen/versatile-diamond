class AliasSpec < SpecificSpec
  attr_reader :name

  def initialize(name, spec_str)
    @name = name
    super(spec_str)
  end
end
