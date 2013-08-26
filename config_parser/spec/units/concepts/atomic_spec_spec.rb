require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe AtomicSpec, termination_spec: true do
      describe "#name" do
        it { adsorbed_h.name.should == :H }
      end

      describe "#full_name" do
        it { adsorbed_h.full_name.should == :H }
      end

      describe "#external_bonds" do
        it { adsorbed_h.external_bonds.should == 1 }
      end

      describe "#same?" do
        it { adsorbed_h.same?(AtomicSpec.new(h.dup)).should be_true }
        it { adsorbed_h.same?(active_bond).should be_false }
        it { adsorbed_h.same?(bridge).should be_false }
      end

      describe "#cover?" do
        it { adsorbed_h.cover?(bridge, cd).should be_true }
        it { adsorbed_h.cover?(activated_bridge, activated_cd).should be_true }
        it { adsorbed_h.cover?(chloride_bridge, chloride_bridge.atom(:ct)).
          should be_true }
        it { adsorbed_h.cover?(activated_methyl_on_bridge, activated_c).
          should be_true }
        it { adsorbed_h.cover?(
          activated_methyl_on_bridge, activated_methyl_on_bridge.atom(:cb)).
          should be_true }
        it { adsorbed_h.cover?(
          activated_methyl_on_incoherent_bridge,
          activated_methyl_on_incoherent_bridge.atom(:cb)).
          should be_true }
        it { adsorbed_h.cover?(methyl_on_dimer, methyl_on_dimer.atom(:cm)).
          should be_true }

        it { adsorbed_h.cover?(methane, c).should be_false }
        it { adsorbed_h.cover?(methyl, activated_c).should be_false }
        it { adsorbed_h.cover?(extra_activated_bridge, extra_activated_cd).
          should be_false }
        it { adsorbed_h.cover?(methyl_on_dimer, methyl_on_dimer.atom(:cr)).
          should be_false }

        it { adsorbed_cl.cover?(bridge, bridge.atom(:ct)).should be_false }
        it { adsorbed_cl.cover?(chloride_bridge, chloride_bridge.atom(:ct)).
          should be_true }
      end

      it_behaves_like "termination spec" do
        subject { adsorbed_h }
      end

      it_behaves_like "visitable" do
        subject { adsorbed_h }
      end
    end

  end
end
