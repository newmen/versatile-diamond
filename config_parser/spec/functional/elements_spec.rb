require 'spec_helper'

module VersatileDiamond
  module Interpreter

    describe Elements do
      let(:elements) { Elements.new }

      it "interpreted result should be stored in Chest" do
        elements.interpret('atom H, valence: 1')
        Tools::Chest.atom(:H).should be_a(Concepts::Atom)
      end

      describe "incorrect atom" do
        let(:syntax_error) { Errors::SyntaxError }
        it "atom name is invalid" do
          expect { elements.interpret('atom wrong, valence: 1') }.
            to raise_error syntax_error
        end

        it "wihtout valence" do
          expect { elements.interpret('atom H') }.to raise_error syntax_error
        end

        it "incorrect valence" do
          expect { elements.interpret('atom H, valence: 0') }.
            to raise_error syntax_error
        end
      end
    end

  end
end
