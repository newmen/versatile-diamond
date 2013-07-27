require 'spec_helper'

module VersatileDiamond
  module Interpreter

    describe GasSpec do
      let(:concept) { Concepts::Spec.new(:spec_name) }
      let(:spec) { Interpreter::GasSpec.new(concept) }
      let(:syntax_error) { Errors::SyntaxError }

      before(:each) do
        Tools::Chest.reset
        Elements.new.interpret('atom N, valence: 3')
      end

      describe "#bond" do
        before(:each) do
          spec.interpret('atoms n1: N, n2: N')
        end

        it { -> { spec.interpret('bond :n1, :n2, face: 100') }.
          should raise_error syntax_error }

        it { -> { spec.interpret('bond :n1, :n2, dir: :front') }.
          should raise_error syntax_error }

        it { -> { spec.interpret('bond :n1, :n2') }.
          should_not raise_error syntax_error }
      end

      describe "#simple_atom" do
        it { -> { spec.interpret('atoms n1: N, n2: N%nh4') }.
          should raise_error syntax_error }
      end
    end

  end
end
