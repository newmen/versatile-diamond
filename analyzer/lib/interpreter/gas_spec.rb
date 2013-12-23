module VersatileDiamond
  module Interpreter

    # Changes behavior when spec is gas spec
    class GasSpec < Spec

      # Gas spec could'n have bond with face or direction
      # @param [Array] atoms the array of atom keynames
      # @option [Symbol] :face the face of bond
      # @option [Symbol] :dir the direction of bond
      # @override
      def bond(*atoms, face: nil, dir: nil)
        syntax_error('.wrong_bond') if face || dir
        super
      end
    end

  end
end
