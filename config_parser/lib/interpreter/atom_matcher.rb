module VersatileDiamond
  module Interpreter

    # Provides method for matching used atom from string
    module AtomMatcher
      # Matches used atom from string and returns matcing result
      # @param [String] used_atom_str the string which contain description of
      #   used atom
      # @raise [Errors::SyntaxError] if atom cannot be matched
      # @return [spec_name_sym, atom_keyname_sym]
      def match_used_atom(used_atom_str)
        match = Matcher.used_atom(used_atom_str)
        match && match.all? ?
          match.map(&:to_sym) :
          syntax_error('matcher.undefined_used_atom', name: used_atom_str)
      end
    end

  end
end
