class Lattice
  class << self
    def [](sign)
      @lattices[sign.to_sym]
    end

    def add(sign, c_class)
      @lattices ||= {}
      @lattices[sign] = new(c_class)
    end
  end

  def initialize(c_class)
    @c_class = c_class
  end
end
