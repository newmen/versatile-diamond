require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe AtomicSpec do
      let(:atom) { Atom.new('H', 1) }
      let(:spec) { AtomicSpec.new(atom) }

      describe "termination spec" do
        it { spec.should be_a(TerminationSpec) }
      end

      describe "#name" do
        it { spec.name.should == :H }
      end

      describe "#external_bonds" do
        it { spec.external_bonds.should == 0 }
      end

      describe "#is_gas?" do
        it { spec.is_gas?.should be_false }
      end

      describe "#extendable?" do
        it { spec.extendable?.should be_false }
      end
    end

  end
end
