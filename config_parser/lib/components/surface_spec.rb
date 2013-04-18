class SurfaceSpec < Spec
  def position(first, second, face: nil, dir: nil)
    syntax_error('.uncomplete_position') unless face && dir
    link(Position, first, second, face: face, dir: dir)
  end

private

  # ugly method :(
  def simple_atom(atom_str)
    atom_name, lattice_symbol = Matcher.specified_atom(atom_str)
    if atom_name && lattice_symbol
      lattice = Lattice[lattice_symbol.to_sym]
      atom = Atom[atom_name]
      if atom
        atom.specify(lattice)
        atom
      end
    else
      super
    end
  end

  def link(*args, **options)
    super do |first, second|
      syntax_error('.incorrect_linking') unless options.empty? || first.specified? || second.specified?
    end
  end
end
