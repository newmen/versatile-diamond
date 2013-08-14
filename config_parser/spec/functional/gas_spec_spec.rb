require 'spec_helper'

module VersatileDiamond
  module Interpreter

    describe GasSpec do
      let(:concept) { Concepts::Spec.new(:spec_name) }
      let(:spec) { Interpreter::GasSpec.new(concept) }
      let(:syntax_error) { Errors::SyntaxError }

      before(:each) do
        Elements.new.interpret('atom N, valence: 3')
      end

      describe "#bond" do
        before(:each) { spec.interpret('atoms n1: N, n2: N') }

        it { expect { spec.interpret('bond :n1, :n2, face: 100') }.
          to raise_error syntax_error }

        it { expect { spec.interpret('bond :n1, :n2, dir: :front') }.
          to raise_error syntax_error }

        it { expect { spec.interpret('bond :n1, :n2') }.to_not raise_error }
      end

      describe "#simple_atom" do
        it { expect { spec.interpret('atoms n1: N, n2: N%nh4') }.
          to raise_error syntax_error }
      end
    end

  end
end
