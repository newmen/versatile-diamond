module VersatileDiamond
  module Interpreter

    # Changes behavior when spec is surface structure
    class SurfaceSpec < Spec
      include PositionErrorsCatcher

      # Surface structure could'n have position with face or direction
      # @param [Array] atoms the array of atom keynames
      # @option [Symbol] :face the face of position
      # @option [Symbol] :dir the direction of position
      # @raise [Errors::SyntaxError] if position without face or direction
      def position(*atoms, face: nil, dir: nil)
        interpret_position_errors do
          link(*atoms, Concepts::Position[face: face, dir: dir])
        end
      end

      # Surface structure could have no position between atoms
      # @param [Array] atoms the array of atom keynames
      # @option [Symbol] :face the face of position
      # @option [Symbol] :dir the direction of position
      # @raise [Errors::SyntaxError] if non position without face or direction
      define_method(:'no-position') do |*atoms, face: nil, dir: nil|
        interpret_position_errors do
          link(*atoms, Concepts::NonPosition[face: face, dir: dir])
        end
      end

    private

      # Matches simple atom with case when it have lattice
      # @param [String] atom_str the string which describe atom
      # @return [Concepts::Atom] matched atom with setted lattice if it was
      #   passed
      # @override
      def simple_atom(keyname, atom_str)
        atom_name, lattice_symbol = Matcher.specified_atom(atom_str)
        if atom_name && lattice_symbol
          atom = get(:atom, atom_name)
          atom.lattice = get(:lattice, lattice_symbol)
          @concept.describe_atom(keyname, atom)
          true
        else
          super
        end
      end
    end

  end
end
