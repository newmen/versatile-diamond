require 'spec_helper'

module VersatileDiamond
  module Interpreter

    describe Elements, type: :interpreter do
      it "interpreted result should be stored in Chest" do
        elements.interpret('atom H, valence: 1')
        expect(Tools::Chest.atom(:H)).to be_a(Concepts::Atom)
      end

      describe "incorrect atom" do
        it "atom name is invalid" do
          expect { elements.interpret('atom wrong, valence: 1') }.
            to raise_error *syntax_error('atom.invalid_name', name: 'wrong')
        end

        it "wihtout valence" do
          expect { elements.interpret('atom H') }.
            to raise_error *syntax_error('atom.without_valence', name: 'H')
        end

        it "incorrect valence" do
          expect { elements.interpret('atom H, valence: 0') }.
            to raise_error *syntax_error('atom.invalid_valence', name: 'H')
        end
      end
    end

  end
end
