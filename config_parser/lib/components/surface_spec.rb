class SurfaceSpec < Spec
  def simple_atom(atom_str)
    if atom_str =~ /\A(?<atom>[A-Z][a-z0-9]*)%(?<lattice>\S+)\Z/
      lattice = Lattice[$~[:lattice]]
      syntax_error('spec.undefined_lattice', lattice: $~[:lattice]) unless lattice

      atom = Atom[$~[:atom]]
      if atom
        atom.specify(lattice)
        atom
      end
    else
      super
    end
  end
end
