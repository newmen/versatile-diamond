require 'spec_helper'

module VersatileDiamond
  module Tools
    describe AtomProperties, use: :atom_properties do

      describe "#==" do
        it { methyl.should_not == high_cm }
        it { high_cm.should_not == methyl }

        it { dimer_cl.should == dimer_cr }
        it { dimer_cr.should == dimer_cl }

        it { bridge_ct.should_not == ab_ct }
        it { ab_ct.should_not == bridge_ct }

        it { ab_ct.should_not == aib_ct }
        it { aib_ct.should_not == ab_ct }
        it { ab_ct.should_not == eab_ct }
        it { eab_ct.should_not == ab_ct }
        it { eab_ct.should_not == aib_ct }
        it { aib_ct.should_not == eab_ct }

        it { aib_ct.should_not == hib_ct }
        it { hib_ct.should_not == aib_ct }

        it { bridge_cr.should_not == hb_cr }
        it { hb_cr.should_not == bridge_cr }
        it { clb_cr.should_not == hb_cr }

        it { ab_cr.should_not == ib_cr }
        it { hb_cr.should_not == ib_cr }
        it { ib_cr.should_not == hb_cr }
      end

      describe "#contained_in?" do
        it { methyl.contained_in?(high_cm).should be_false }
        it { high_cm.contained_in?(methyl).should be_false }

        it { methyl.contained_in?(bridge_cr).should be_false }
        it { bridge_cr.contained_in?(methyl).should be_false }

        it { bridge_ct.contained_in?(bridge_cr).should be_true }
        it { bridge_ct.contained_in?(dimer_cr).should be_true }
        it { bridge_ct.contained_in?(ab_ct).should be_true }
        it { bridge_ct.contained_in?(aib_ct).should be_true }
        it { bridge_ct.contained_in?(hb_ct).should be_true }

        it { dimer_cr.contained_in?(ad_cr).should be_true }
        it { ad_cr.contained_in?(dimer_cr).should be_false }

        it { ab_ct.contained_in?(ad_cr).should be_true }
        it { ad_cr.contained_in?(ab_ct).should be_false }

        it { ab_ct.contained_in?(eab_ct).should be_true }
        it { eab_ct.contained_in?(ab_ct).should be_false }
        it { hb_ct.contained_in?(ehb_ct).should be_true }
        it { ehb_ct.contained_in?(hb_ct).should be_false }

        it { dimer_cr.contained_in?(bridge_ct).should be_false }
        it { dimer_cr.contained_in?(bridge_cr).should be_false }
        it { ab_ct.contained_in?(bridge_cr).should be_false }
        it { ab_ct.contained_in?(hb_ct).should be_false }
        it { hb_ct.contained_in?(bridge_ct).should be_false }
        it { clb_cr.contained_in?(bridge_cr).should be_false }
        it { clb_cr.contained_in?(hb_cr).should be_false }
        it { bridge_cr.contained_in?(ab_ct).should be_false }
        it { bridge_cr.contained_in?(clb_cr).should be_true }

        it { ab_ct.contained_in?(ahb_ct).should be_true }
        it { hb_ct.contained_in?(ahb_ct).should be_true }
        it { ahb_ct.contained_in?(ab_ct).should be_false }
        it { ahb_ct.contained_in?(hb_ct).should be_false }

        it { ab_ct.contained_in?(aib_ct).should be_true }
        it { aib_ct.contained_in?(ab_ct).should be_false }
        it { hb_ct.contained_in?(hib_ct).should be_true }
        it { hib_ct.contained_in?(hb_ct).should be_false }
        it { bridge_cr.contained_in?(ab_cr).should be_true }
        it { ab_cr.contained_in?(bridge_cr).should be_false }
        it { bridge_cr.contained_in?(hb_cr).should be_true }
        it { hb_cr.contained_in?(bridge_cr).should be_false }
        it { bridge_cr.contained_in?(ib_cr).should be_true }
        it { ib_cr.contained_in?(bridge_cr).should be_false }

        it { aib_ct.contained_in?(ahb_ct).should be_false }
        it { ib_cr.contained_in?(hb_cr).should be_false }
        it { ab_cr.contained_in?(ib_cr).should be_false }
        it { hb_cr.contained_in?(ib_cr).should be_false }
        it { ahb_ct.contained_in?(aib_ct).should be_false }
      end

      describe "#same_incoherent?" do
        it { ab_ct.same_incoherent?(ad_cr).should be_false }
        it { ab_ct.same_incoherent?(eab_ct).should be_false }
        it { ab_ct.same_incoherent?(aib_ct).should be_false }
        it { ad_cr.same_incoherent?(ab_ct).should be_false }
        it { eab_ct.same_incoherent?(ab_ct).should be_false }
        it { aib_ct.same_incoherent?(eab_ct).should be_false }
        it { aib_ct.same_incoherent?(ahb_ct).should be_false }
        it { hb_ct.same_incoherent?(ahb_ct).should be_false }
        it { hb_ct.same_incoherent?(hib_ct).should be_false }
        it { hib_ct.same_incoherent?(ahb_ct).should be_false }
        it { hib_ct.same_incoherent?(ehb_ct).should be_false }
        it { ib_cr.same_incoherent?(hb_cr).should be_false }
        it { ib_cr.same_incoherent?(ab_cr).should be_false }
        it { hb_cr.same_incoherent?(ab_cr).should be_false }
        it { ab_cr.same_incoherent?(hb_cr).should be_false }
        it { clb_cr.same_incoherent?(hb_cr).should be_false }

        it { ehb_ct.same_incoherent?(hib_ct).should be_true }
        it { eab_ct.same_incoherent?(aib_ct).should be_true }
        it { ahb_ct.same_incoherent?(hib_ct).should be_true }
        it { ahb_ct.same_incoherent?(aib_ct).should be_true }
        it { hb_cr.same_incoherent?(ib_cr).should be_true }
        it { ab_cr.same_incoherent?(ib_cr).should be_true }
        it { clb_cr.same_incoherent?(ib_cr).should be_true }
      end

      describe "#same_hydrogens?" do
        it { ab_ct.same_hydrogens?(ad_cr).should be_false }
        it { ab_ct.same_hydrogens?(eab_ct).should be_false }
        it { ad_cr.same_hydrogens?(ab_ct).should be_false }
        it { ahb_ct.same_hydrogens?(hib_ct).should be_false }
        it { aib_ct.same_hydrogens?(eab_ct).should be_false }
        it { eab_ct.same_hydrogens?(ab_ct).should be_false }
        it { eab_ct.same_hydrogens?(aib_ct).should be_false }
        it { hb_ct.same_hydrogens?(ahb_ct).should be_false }
        it { hib_ct.same_hydrogens?(ahb_ct).should be_false }
        it { ab_cr.same_hydrogens?(hb_cr).should be_false }
        it { ab_cr.same_hydrogens?(ib_cr).should be_false }
        it { hb_cr.same_hydrogens?(ab_cr).should be_false }
        it { ib_cr.same_hydrogens?(ab_cr).should be_false }
        it { clb_cr.same_hydrogens?(hb_cr).should be_false }

        it { bridge_ct.same_hydrogens?(ehb_ct).should be_true }
        it { bridge_ct.same_hydrogens?(hb_ct).should be_true }
        it { bridge_ct.same_hydrogens?(hib_ct).should be_true }
        it { ab_ct.same_hydrogens?(aib_ct).should be_true }
        it { ahb_ct.same_hydrogens?(aib_ct).should be_true }
        it { aib_ct.same_hydrogens?(ahb_ct).should be_true }
        it { ehb_ct.same_hydrogens?(hib_ct).should be_true }
        it { hb_ct.same_hydrogens?(hib_ct).should be_true }
        it { hib_ct.same_hydrogens?(ehb_ct).should be_true }
        it { hb_cr.same_hydrogens?(ib_cr).should be_true }
        it { clb_cr.same_hydrogens?(ab_cr).should be_true }
        it { ib_cr.same_hydrogens?(hb_cr).should be_true }
      end

      describe "#terminations_num" do
        it { methyl.terminations_num(active_bond).should == 0 }
        it { methyl.terminations_num(adsorbed_h).should == 3 }

        it { high_cm.terminations_num(active_bond).should == 0 }
        it { high_cm.terminations_num(adsorbed_h).should == 2 }

        it { bridge_cr.terminations_num(active_bond).should == 0 }
        it { bridge_cr.terminations_num(adsorbed_h).should == 1 }

        it { ab_ct.terminations_num(active_bond).should == 1 }
        it { ab_ct.terminations_num(adsorbed_h).should == 1 }

        it { ad_cr.terminations_num(active_bond).should == 1 }
        it { ad_cr.terminations_num(adsorbed_h).should == 0 }

        it { eab_ct.terminations_num(active_bond).should == 2 }
        it { eab_ct.terminations_num(adsorbed_h).should == 0 }

        it { hb_ct.terminations_num(active_bond).should == 0 }
        it { hb_ct.terminations_num(adsorbed_h).should == 2 }

        it { ehb_ct.terminations_num(active_bond).should == 0 }
        it { ehb_ct.terminations_num(adsorbed_h).should == 2 }

        it { ahb_ct.terminations_num(active_bond).should == 1 }
        it { ahb_ct.terminations_num(adsorbed_h).should == 1 }

        it { ib_cr.terminations_num(active_bond).should == 0 }
        it { ib_cr.terminations_num(adsorbed_h).should == 1 }

        it { hb_cr.terminations_num(active_bond).should == 0 }
        it { hb_cr.terminations_num(adsorbed_h).should == 1 }

        it { ab_cr.terminations_num(active_bond).should == 1 }
        it { ab_cr.terminations_num(adsorbed_h).should == 0 }

        it { clb_cr.terminations_num(active_bond).should == 0 }
        it { clb_cr.terminations_num(adsorbed_h).should == 0 }

        it { expect { bridge_ct.terminations_num(bridge_base) }.
          to raise_error ArgumentError }
        it { expect { bridge_ct.terminations_num(bridge) }.
          to raise_error ArgumentError }
      end

      describe "#unrelevanted" do
        it { bridge_ct.unrelevanted.should == bridge_ct }
        it { bridge_ct.should == bridge_ct.unrelevanted }

        it { bridge_ct.should_not == ab_ct.unrelevanted }
        it { ab_ct.unrelevanted.should_not == bridge_ct }

        it { aib_ct.unrelevanted.should == ab_ct }
        it { hib_ct.unrelevanted.should == hb_ct }

        it { ib_cr.unrelevanted.should == bridge_cr }
        it { ab_cr.unrelevanted.should == ab_cr }
        it { hb_cr.unrelevanted.should == hb_cr }
        it { clb_cr.unrelevanted.should == clb_cr }
      end

      describe "#incoherent?" do
        it { high_cm.incoherent?.should be_false }
        it { bridge_ct.incoherent?.should be_false }
        it { ab_ct.incoherent?.should be_false }
        it { eab_ct.incoherent?.should be_false }
        it { ahb_ct.incoherent?.should be_false }
        it { hb_ct.incoherent?.should be_false }
        it { ehb_ct.incoherent?.should be_false }
        it { bridge_cr.incoherent?.should be_false }
        it { ab_cr.incoherent?.should be_false }
        it { hb_cr.incoherent?.should be_false }
        it { clb_cr.incoherent?.should be_false }
        it { dimer_cr.incoherent?.should be_false }
        it { ad_cr.incoherent?.should be_false }

        it { aib_ct.incoherent?.should be_true }
        it { hib_ct.incoherent?.should be_true }
        it { ib_cr.incoherent?.should be_true }
      end

      describe "#incoherent" do
        it { methyl.incoherent.should_not be_nil }
        it { high_cm.incoherent.should_not be_nil }

        it { ab_ct.incoherent.should == aib_ct }
        it { aib_ct.incoherent.should be_nil }
        it { eab_ct.incoherent.should be_nil }

        it { bridge_cr.incoherent.should_not be_nil }
        it { bridge_cr.incoherent.should_not == aib_ct }

        it { ad_cr.incoherent.should be_nil }

        it { hb_ct.incoherent.should == hib_ct }
        it { hib_ct.incoherent.should be_nil }
        it { ahb_ct.incoherent.should be_nil }
        it { ehb_ct.incoherent.should be_nil }

        it { ab_cr.incoherent.should be_nil }
        it { hb_cr.incoherent.should be_nil }
        it { ib_cr.incoherent.should be_nil }
      end

      describe "#relevant?" do
        it { high_cm.relevant?.should be_false }
        it { bridge_ct.relevant?.should be_false }
        it { ad_cr.relevant?.should be_false }
        it { eab_ct.relevant?.should be_false }
        it { hb_ct.relevant?.should be_false }
        it { ehb_ct.relevant?.should be_false }
        it { ahb_ct.relevant?.should be_false }
        it { clb_cr.relevant?.should be_false }

        it { methyl.relevant?.should be_true }
        it { aib_ct.relevant?.should be_true }
        it { hib_ct.relevant?.should be_true }
      end

      describe "activated" do
        it { methyl.activated.should_not be_nil }
        it { high_cm.activated.should_not be_nil }

        it { bridge_ct.activated.should == ab_ct }
        it { ab_ct.activated.should == eab_ct }
        it { eab_ct.activated.should be_nil }
        it { ad_cr.activated.should be_nil }

        it { bridge_cr.activated.activated.should be_nil }

        it { hb_ct.activated.should == ahb_ct }
        it { ehb_ct.activated.should be_nil }
        it { ahb_ct.activated.should be_nil }

        it { ab_cr.activated.should be_nil }
        it { hb_cr.activated.should be_nil }
        it { ib_cr.activated.should_not be_nil }
      end

      describe "deactivated" do
        it { methyl.deactivated.should be_nil }
        it { high_cm.deactivated.should be_nil }

        it { bridge_ct.deactivated.should be_nil }
        it { ab_ct.deactivated.should == bridge_ct }
        it { eab_ct.deactivated.should == ab_ct }

        it { ab_ct.deactivated.deactivated.should be_nil }

        it { ahb_ct.deactivated.should == hb_ct }
        it { ab_cr.deactivated.should == bridge_cr }

        it { hb_ct.deactivated.should be_nil }
        it { ehb_ct.deactivated.should be_nil }
        it { hb_cr.deactivated.should be_nil }
        it { ib_cr.deactivated.should be_nil }
      end

      describe "#dangling_hydrogens_num" do
        it { bridge_ct.dangling_hydrogens_num.should == 0 }
        it { ab_ct.dangling_hydrogens_num.should == 0 }
        it { ahb_ct.dangling_hydrogens_num.should == 1 }
        it { aib_ct.dangling_hydrogens_num.should == 0 }
        it { eab_ct.dangling_hydrogens_num.should == 0 }
        it { ehb_ct.dangling_hydrogens_num.should == 2 }
        it { hb_ct.dangling_hydrogens_num.should == 1 }
        it { hib_ct.dangling_hydrogens_num.should == 1 }
        it { ib_cr.dangling_hydrogens_num.should == 0 }
        it { ab_cr.dangling_hydrogens_num.should == 0 }
        it { hb_cr.dangling_hydrogens_num.should == 1 }
        it { clb_cr.dangling_hydrogens_num.should == 0 }
        it { ad_cr.dangling_hydrogens_num.should == 0 }
      end

      describe "#smallests" do
        it { bridge_ct.smallests.should be_nil }
        it { ab_ct.smallests.should be_nil }

        describe "#add_smallest" do
          before(:each) { ab_ct.add_smallest(bridge_ct) }
          it { bridge_ct.smallests.should be_nil }
          it { ab_ct.smallests.to_a.should == [bridge_ct] }
        end
      end

      describe "#sames" do
        it { aib_ct.sames.should be_nil }
        it { eab_ct.sames.should be_nil }

        describe "#add_same" do
          before(:each) { eab_ct.add_same(aib_ct) }
          it { aib_ct.sames.should be_nil }
          it { eab_ct.sames.to_a.should == [aib_ct] }
        end
      end

      describe "#size" do
        it { methyl.size.should == 5.13 }
        it { high_cm.size.should == 6 }

        it { bridge_ct.size.should == 6.5 }
        it { bridge_cr.size.should == 8.5 }
        it { dimer_cr.size.should == 7.5 }

        it { ab_ct.size.should == 6.84 }
        it { aib_ct.size.should == 6.97 }
        it { eab_ct.size.should == 7.18 }

        it { hb_ct.size.should == 6.84 }
        it { hib_ct.size.should == 6.97 }
        it { ehb_ct.size.should == 7.18 }
        it { ahb_ct.size.should == 7.18 }

        it { ib_cr.size.should == 8.63 }
        it { ab_cr.size.should == 8.84 }
        it { hb_cr.size.should == 8.84 }
        it { clb_cr.size.should == 8.84 }
      end

      describe "#to_s" do
        it { methyl.to_s.should == 'C:u~' }
        it { high_cm.to_s.should == 'C=' }

        it { bridge_ct.to_s.should == 'C%d<' }
        it { bridge_cr.to_s.should == '^C.%d<' }
        it { dimer_cr.to_s.should == '-C%d<' }

        it { ad_cr.to_s.should == '-*C%d<' }
        it { ab_ct.to_s.should == '*C%d<' }
        it { aib_ct.to_s.should == '*C:i%d<' }
        it { eab_ct.to_s.should == '**C%d<' }

        it { hb_ct.to_s.should == 'HC%d<' }
        it { ehb_ct.to_s.should == 'HHC%d<' }
        it { ahb_ct.to_s.should == 'H*C%d<' }
        it { hib_ct.to_s.should == 'HC:i%d<' }

        it { ab_cr.to_s.should == '^*C.%d<' }
        it { hb_cr.to_s.should == '^HC.%d<' }
        it { ib_cr.to_s.should == '^C.:i%d<' }
      end
    end

  end
end
