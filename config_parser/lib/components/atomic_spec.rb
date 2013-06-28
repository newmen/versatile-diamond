module VersatileDiamond

  class AtomicSpec < TerminationSpec
    include SyntaxChecker

    def initialize(atom_name)
      @atom = Atom[atom_name]
      syntax_error('.invalid_valence') if @atom.valence != 1
    end

    def name
      @atom.name
    end

    def external_bonds
      @atom.valence
    end

    def to_s
      @atom.to_s
    end

    def cover?(specific_spec)
      # i don't love it condition
      !specific_spec.active? && ((Run.instance.is_termination?(name) &&
        specific_spec.external_bonds > 0) ||
          specific_spec.has_atom?(@atom))
    end
  end

end
