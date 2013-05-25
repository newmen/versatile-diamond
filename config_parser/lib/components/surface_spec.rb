module VersatileDiamond

  class SurfaceSpec < Spec
    def position(first, second, face: nil, dir: nil)
      link(Position, first, second, face: face, dir: dir)
    end

  private

    def simple_atom(atom_str)
      atom_name, lattice_symbol = Matcher.specified_atom(atom_str)
      if atom_name && lattice_symbol
        atom = Atom[atom_name]
        atom.specify(Lattice[lattice_symbol.to_sym])
        atom
      else
        super
      end
    end

    def link(*args, **options)
      super(*args, options) do |first, second|
        syntax_error('.incorrect_linking') unless options.empty? || first.specified? || second.specified?
      end
    end
  end

end
