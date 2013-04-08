class Gas
  def spec(name, &block)
    GasSpec.add(name, &block)
  end
end
