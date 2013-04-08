class SurfaceSpec < Spec
  def method_missing(name, *args, &block)
    Lattice[name] || super
  end
end
