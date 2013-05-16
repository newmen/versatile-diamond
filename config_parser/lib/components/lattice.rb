class Lattice
  class << self
    include SyntaxChecker

    def add(symbol, cpp_class)
      @lattices ||= {}
      syntax_error('.already_defined') if @lattices[symbol]
      @lattices[symbol] = new(symbol, cpp_class)
    end

    def [](symbol)
      @lattices[symbol] || syntax_error('.undefined', symbol: symbol)
    end
  end

  def initialize(symbol, cpp_class)
    @symbol, @cpp_class = symbol, cpp_class
  end

  def to_s
    @symbol.to_s
  end
end
