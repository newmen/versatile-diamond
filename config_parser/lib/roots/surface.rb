class Surface
  def lattice(sign, c_class: c_class)
    raise 'Need to define class when defining new lattice' unless c_class
    Lattice.add(sign, c_class)
  end

  def spec(name, &block)
    SurfaceSpec.add(name, &block)
  end
end
