module VersatileDiamond
  module Interpreter

    class GasSpec < Spec
      def bond(first, second, face: nil, dir: nil)
        syntax_error('.wrong_bond') if face || dir
        super
      end
    end

  end
end
