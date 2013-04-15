class AtomReference
  def initialize(spec, atom_sym)
    @spec, @atom_sym = spec, atom_sym
  end

  def specified?
    @spec[@atom_sym].specified?
  end
end
