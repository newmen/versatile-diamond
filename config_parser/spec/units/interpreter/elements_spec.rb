require 'spec_helper'

module VersatileDiamond
  module Interpreter

    describe Elements do
      let(:target) { Elements.new }

      it { target.interpret('atom H, valence: 1').should be_a(Concepts::Atom) }

      describe "incorrect atom" do
        let(:syntax_error) { Errors::SyntaxError }
        it "atom name is invalid" do
          -> { target.interpret('atom wrong, valence: 1') }.
            should raise_error syntax_error
        end

        it "wihtout valence" do
          -> { target.interpret('atom H') }.should raise_error syntax_error
        end

        it "incorrect valence" do
          -> { target.interpret('atom H, valence: 0') }.
            should raise_error syntax_error
        end
      end
    end

  end
end
