require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe ActiveBond do
      describe "termination spec" do
        it { active_bond.should be_a(TerminationSpec) }
      end

      describe "#name" do
        it { active_bond.name.should == :* }
      end

      describe "#external_bonds" do
        it { active_bond.external_bonds.should == 0 }
      end

      describe "#is_gas?" do
        it { active_bond.is_gas?.should be_false }
      end

      describe "#extendable?" do
        it { active_bond.extendable?.should be_false }
      end
    end

  end
end
