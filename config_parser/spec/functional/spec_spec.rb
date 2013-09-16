require 'spec_helper'

module VersatileDiamond
  module Interpreter

    describe Spec, type: :interpreter do
      let(:concept) { Concepts::Spec.new(:spec_name) }
      let(:spec) { Interpreter::Spec.new(concept) }

      before(:each) do
        elements.interpret('atom N, valence: 3')
      end

      describe "#atoms" do
        it "atoms line becomes to concept as instances of Atom" do
          spec.interpret('atoms n: N')
          concept.atom(:n).name.should == :N
        end
      end

      describe "#aliases" do
        context "undefined spec" do
          it { expect { spec.interpret('aliases ng: nitrogen') }.
            to raise_error *keyname_error(:undefined, :spec, :nitrogen) }
        end
      end
    end

  end
end
