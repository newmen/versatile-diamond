require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe ActiveBond, termination_spec: true do
      describe "#name" do
        it { active_bond.name.should == :* }
      end

      describe "#full_name" do
        it { active_bond.full_name.should == :* }
      end

      describe "#external_bonds" do
        it { active_bond.external_bonds.should == 0 }
      end

      describe "#same?" do
        it { active_bond.same?(ActiveBond.new).should be_true }
        it { active_bond.same?(adsorbed_h).should be_false }
        it { active_bond.same?(bridge).should be_false }
      end

      describe "#cover?" do
        it { active_bond.cover?(activated_methyl_on_dimer, activated_c).
          should be_true }
        it { active_bond.cover?(
          methyl_on_activated_bridge, methyl_on_activated_bridge.atom(:cb)).
          should be_true }
        it { active_bond.cover?(activated_bridge, activated_cd).
          should be_true }
        it { active_bond.cover?(extra_activated_bridge, extra_activated_cd).
          should be_true }
        it { active_bond.cover?(activated_incoherent_bridge, activated_c).
          should be_true }
        it { active_bond.cover?(activated_dimer, activated_cd).should be_true }

        it { active_bond.cover?(methyl, c).should be_false }
        it { active_bond.cover?(bridge, cd).should be_false }
        it { active_bond.cover?(chloride_bridge, chloride_bridge.atom(:ct)).
          should be_false }
        it { active_bond.cover?(methyl_on_bridge, c).should be_false }
        it { active_bond.cover?(
          activated_incoherent_bridge, incoherent_cd).
          should be_false }
        it { active_bond.cover?(
          activated_methyl_on_dimer, activated_methyl_on_dimer.atom(:cr)).
          should be_false }
      end

      it_behaves_like "termination spec" do
        subject { active_bond }
      end

      it_behaves_like "visitable" do
        subject { active_bond }
      end
    end

  end
end
