class Lattice
  class << self
    include SyntaxChecker

    def [](symbol)
      @lattices[symbol] || syntax_error('.undefined', symbol: symbol)
    end

    def add(symbol, cpp_class)
      @lattices ||= {}
      syntax_error('.already_defined') if @lattices[symbol]
      @lattices[symbol] = new(cpp_class)
    end
  end

  def initialize(cpp_class)
    @cpp_class = cpp_class
  end
end
