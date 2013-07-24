module VersatileDiamond

  module Interpreter

    # Interpret elements block
    class Elements < Component
      # Creates atom
      # @param [String] name the name of atom
      # @option valence [Integer] the valence of atom
      # @raise [Errors::SyntaxError] if valence is not passed or used invalid
      #   atom name
      # @return [Concepts::Atom] new atom
      def atom(name, valence: nil)
        syntax_error('atom.invalid_name', name: name) unless Matcher.atom(name)
        syntax_error('atom.without_valence', name: name) unless valence
        syntax_error('atom.invalid_valence', name: name) if valence.to_i <= 0
        Concepts::Atom.new(name, valence)
      end
    end

  end

end
