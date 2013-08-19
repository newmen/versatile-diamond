module VersatileDiamond
  module Interpreter

    # Interprets surface block
    class Surface < Phase

      # Interprets lattice line, creates correspond lattice and store it to
      # Chest
      #
      # @param [Symbol] sign the name of lattice
      # @option [String] :cpp_class the C++ class of described lattice
      # @raise [Errors::SyntaxError] if lattice haven't cpp_class declaration
      def lattice(sign, cpp_class: nil)
        raise syntax_error('lattice.need_define_class') unless cpp_class
        Tools::Chest.store(Lattice.new(sign, cpp_class))
      end

      # Interpret size line, checks passed values and store them to Config
      # @option [Integer] :x the size of surface on X axis
      # @option [Integer] :y the size of surface on Y axis
      # @raise [Errors::SyntaxError] if one of dimension is not passed
      # @raise [Tools::Config::AlreadyDefined] if sizes are already defined
      def size(x: nil, y: nil)
        syntax_error('.wrong_sizes') unless x && y
        Tools::Config.surface_sizes(x: x, y: y)
      end

      # Interpret composition line, checks passed atom to specified atom and
      #   store it value to Config
      #
      # @param [String] atom_str the string which describe atom
      # @raise [Errors::SyntaxError] if atom is not specified by lattice
      # @raise [Tools::Chest::KeyNameError] if atom is undefined
      # @raise [Tools::Config::AlreadyDefined] if composition already defined
      def composition(atom_str)
        atom_name, lattice_symbol = Matcher.specified_atom(atom_str)
        unless atom_name && lattice_symbol
          syntax_error('.need_pass_specified_atom')
        end

        atom = Tools::Chest.atom(atom_name)
        atom.lattice = Tools::Chest.lattice(lattice_symbol)
        Tools::Config.surface_composition(atom)
      end

    private

      def interpreter_class
        Interpreter::SurfaceSpec
      end

      def concept_class
        Concepts::SurfaceSpec
      end
    end

  end
end
