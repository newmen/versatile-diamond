module VersatileDiamond
  module Interpreter

    # Interprets surface block
    class Surface < Phase

      # Interprets lattice line, creates correspond lattice and store it to
      # Chest
      #
      # @param [Symbol] sign the name of lattice
      # @option [String] :class the class of described lattice
      # @raise [Errors::SyntaxError] if lattice haven't class declaration
      def lattice(sign, **options)
        raise syntax_error('lattice.need_define_class') unless options[:class]
        store(Lattice.new(sign, options[:class]))
      end

      # Interpret size line, checks passed values and store them to Config
      # @option [Integer] :x the size of surface on X axis
      # @option [Integer] :y the size of surface on Y axis
      # @raise [Errors::SyntaxError] if one of dimension is not passed or if
      #   sizes are already defined
      def size(x: nil, y: nil)
        syntax_error('.wrong_sizes') unless x && y
        Tools::Config.surface_sizes(x: x, y: y)
      rescue Tools::Config::AlreadyDefined
        syntax_error('.sizes_already_set')
      end

      # Interpret composition line, checks passed atom to specified atom and
      #   store it value to Config
      #
      # @param [String] atom_str the string which describe atom
      # @raise [Errors::SyntaxError] if atom is not specified by lattice or if
      #   atom is undefined or if composition already defined
      def composition(atom_str)
        atom_name, lattice_symbol = Matcher.specified_atom(atom_str)
        unless atom_name && lattice_symbol
          syntax_error('.need_pass_specified_atom')
        end

        atom = get(:atom, atom_name)
        atom.lattice = get(:lattice, lattice_symbol)
        Tools::Config.surface_composition(atom)
      rescue Tools::Config::AlreadyDefined
        syntax_error('.composition_already_set')
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
