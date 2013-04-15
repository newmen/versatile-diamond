class Surface < Phase
  def spec_class
    SurfaceSpec
  end

  def lattice(sign, cpp_class: nil)
    raise syntax_error('.lattice.need_define_class') unless cpp_class
    Lattice.add(sign, cpp_class)
  end
end
