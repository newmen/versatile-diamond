class Lattice
  class << self
    def [](sign)
      @lattices[sign.to_sym]
    end

    def add(sign, cpp_class)
      @lattices ||= {}
      @lattices[sign] = new(cpp_class)
    end
  end

  def initialize(cpp_class)
    @cpp_class = cpp_class
  end
end
