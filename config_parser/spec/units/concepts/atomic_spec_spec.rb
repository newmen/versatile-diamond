require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe AtomicSpec do
      describe "termination spec" do
        it { adsorbed_h.should be_a(TerminationSpec) }
      end

      describe "#name" do
        it { adsorbed_h.name.should == :H }
      end

      describe "#external_bonds" do
        it { adsorbed_h.external_bonds.should == 1 }
      end

      describe "#is_gas?" do
        it { adsorbed_h.is_gas?.should be_false }
      end

      describe "#extendable?" do
        it { adsorbed_h.extendable?.should be_false }
      end
    end

  end
end
