module VersatileDiamond
  module Support

    module DefineAtomsHelper
      # @param [Symbol] spec_raw_call
      # @param [Array] keynames
      # @param [Array] letnames
      # @yield [Symbol] optional handler of iterating keynames
      def let_atoms_of(spec_raw_call, keynames, letnames = keynames, &block)
        let_proc = let_atom_proc(spec_raw_call)
        keynames.zip(letnames).each do |keyname, letname|
          let_proc[keyname, letname]
          block[keyname] if block_given?
        end
      end

    private

      # @param [Symbol] spec_raw_call
      def let_atom_proc(spec_raw_call)
        -> keyname, letname = keyname do
          let(letname) { eval(spec_raw_call.to_s).atom(keyname) }
        end
      end
    end

  end
end
