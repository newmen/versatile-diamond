module VersatileDiamond

  module AtomMatcher
    # @return [spec_name_sym, atom_keyname_sym]
    def match_used_atom(used_atom_str)
      match = Matcher.used_atom(used_atom_str)
      match && match.all? ?
        match.map(&:to_sym) :
        syntax_error('matcher.undefined_used_atom', name: used_atom_str)
    end
  end

end
