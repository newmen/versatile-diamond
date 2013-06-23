module VersatileDiamond

  class Surface < Phase
    def initialize
      super
      @size = {}
    end

    def spec_class
      SurfaceSpec
    end

    def lattice(sign, cpp_class: nil)
      raise syntax_error('lattice.need_define_class') unless cpp_class
      Lattice.add(sign, cpp_class)
    end

    def size(x: nil, y: nil)
      syntax_error('.wrong_sizes') unless x && y
      syntax_error('.sizes_already_set') unless @size.empty?
      @size[:x] = x
      @size[:y] = y
    end

    def composition(atom_str)
      atom_name, lattice_symbol = Matcher.specified_atom(atom_str)
      syntax_error('.need_pass_specified_atom') unless atom_name && lattice_symbol
      atom = Atom[atom_name] || syntax_error('atom.undefined', name: atom_name)
      atom.lattice = Lattice[lattice_symbol.to_sym]
      @composition = atom
    end
  end

end
