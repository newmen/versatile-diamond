require 'spec_helper'

module VersatileDiamond
  module Tools
    describe AtomProperties, use: :atom_properties do

      describe "#==" do
        it { methyl.should_not == high_cm }
        it { high_cm.should_not == methyl }

        it { high_cm.should_not == bridge_ct }
        it { bridge_ct.should_not == high_cm }

        it { bridge_ct.should_not == methyl }
        it { methyl.should_not == bridge_ct }

        it { bridge_ct.should_not == bridge_cr }
        it { bridge_cr.should_not == bridge_ct }

        it { bridge_ct.should_not == dimer_cr }
        it { dimer_cr.should_not == bridge_ct }

        it { dimer_cl.should == dimer_cr }
        it { dimer_cr.should == dimer_cl }

        it { bridge_ct.should_not == ab_ct }
        it { ab_ct.should_not == bridge_ct }

        it { ab_ct.should_not == aib_ct }
        it { aib_ct.should_not == ab_ct }

        it { ab_ct.should_not == eab_ct }
        it { eab_ct.should_not == ab_ct }

        it { aib_ct.should_not == eab_ct }
        it { eab_ct.should_not == aib_ct }

        it { ab_ct.should_not == hb_ct }
        it { hb_ct.should_not == ab_ct }

        it { ab_ct.should_not == ahb_ct }
        it { ahb_ct.should_not == ab_ct }

        it { ahb_ct.should_not == hib_ct }
        it { hib_ct.should_not == ahb_ct }
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

        it { dimer_cr.contained_in?(bridge_ct).should be_false }
        it { dimer_cr.contained_in?(bridge_cr).should be_false }
        it { ab_ct.contained_in?(bridge_cr).should be_false }
        it { ab_ct.contained_in?(hb_ct).should be_false }
        it { hb_ct.contained_in?(bridge_ct).should be_false }
        it { bridge_cr.contained_in?(ab_ct).should be_false }

        it { ab_ct.contained_in?(ahb_ct).should be_true }
        it { hb_ct.contained_in?(ahb_ct).should be_true }
        it { ahb_ct.contained_in?(ab_ct).should be_false }
        it { ahb_ct.contained_in?(hb_ct).should be_false }

        it { ab_ct.contained_in?(aib_ct).should be_true }
        it { aib_ct.contained_in?(ab_ct).should be_false }
        it { hb_ct.contained_in?(hib_ct).should be_true }
        it { hib_ct.contained_in?(hb_ct).should be_false }
      end

      describe "#same_incoherent?" do
        it { ab_ct.same_incoherent?(ad_cr).should be_false }
        it { ad_cr.same_incoherent?(ab_ct).should be_false }
        it { eab_ct.same_incoherent?(ab_ct).should be_false }
        it { aib_ct.same_incoherent?(eab_ct).should be_false }
        it { aib_ct.same_incoherent?(ahb_ct).should be_false }
        it { ab_ct.same_incoherent?(eab_ct).should be_false }
        it { ab_ct.same_incoherent?(aib_ct).should be_false }
        it { hb_ct.same_incoherent?(hib_ct).should be_false }
        it { hb_ct.same_incoherent?(ahb_ct).should be_false }
        it { hib_ct.same_incoherent?(ahb_ct).should be_false }

        it { eab_ct.same_incoherent?(aib_ct).should be_true }
        it { ahb_ct.same_incoherent?(aib_ct).should be_true }
        it { ahb_ct.same_incoherent?(hib_ct).should be_true }
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

        it { ahb_ct.terminations_num(active_bond).should == 1 }
        it { ahb_ct.terminations_num(adsorbed_h).should == 1 }

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
      end

      describe "#incoherent?" do
        it { high_cm.incoherent?.should be_false }
        it { ab_ct.incoherent?.should be_false }
        it { bridge_ct.incoherent?.should be_false }
        it { bridge_cr.incoherent?.should be_false }
        it { dimer_cr.incoherent?.should be_false }
        it { ad_cr.incoherent?.should be_false }
        it { ab_ct.incoherent?.should be_false }
        it { eab_ct.incoherent?.should be_false }
        it { hb_ct.incoherent?.should be_false }
        it { ahb_ct.incoherent?.should be_false }

        it { aib_ct.incoherent?.should be_true }
        it { hib_ct.incoherent?.should be_true }
      end

      describe "#incoherent" do
        it { methyl.incoherent.should_not be_nil }
        it { high_cm.incoherent.should_not be_nil }

        it { ab_ct.incoherent.should == aib_ct }
        it { aib_ct.incoherent.should be_nil }

        it { bridge_cr.incoherent.should_not be_nil }
        it { bridge_cr.incoherent.should_not == aib_ct }

        it { ad_cr.incoherent.should be_nil }

        it { hb_ct.incoherent.should == hib_ct }
        it { hib_ct.incoherent.should be_nil }
        it { ahb_ct.incoherent.should be_nil }
      end

      describe "#relevant?" do
        it { high_cm.relevant?.should be_false }
        it { bridge_ct.relevant?.should be_false }
        it { ad_cr.relevant?.should be_false }
        it { eab_ct.relevant?.should be_false }
        it { hb_ct.relevant?.should be_false }
        it { ahb_ct.relevant?.should be_false }

        it { methyl.relevant?.should be_true }
        it { aib_ct.relevant?.should be_true }
        it { hib_ct.relevant?.should be_true }
      end

      describe "activated" do
        it { methyl.activated.should_not be_nil }
        it { high_cm.activated.should_not be_nil }

        it { bridge_ct.activated.should == ab_ct }
        it { ab_ct.activated.should == eab_ct }
        it { ad_cr.activated.should be_nil }

        it { bridge_cr.activated.activated.should be_nil }

        it { hb_ct.activated.should == ahb_ct }
        it { ahb_ct.activated.should be_nil }
      end

      describe "deactivated" do
        it { methyl.deactivated.should be_nil }
        it { high_cm.deactivated.should be_nil }

        it { bridge_ct.deactivated.should be_nil }
        it { ab_ct.deactivated.should == bridge_ct }
        it { eab_ct.deactivated.should == ab_ct }

        it { ab_ct.deactivated.deactivated.should be_nil }

        it { ahb_ct.deactivated.should == hb_ct }
        it { hb_ct.deactivated.should be_nil }
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
        it { methyl.size.should == 5.34 }
        it { high_cm.size.should == 6 }

        it { bridge_ct.size.should == 6.5 }
        it { bridge_cr.size.should == 8.5 }
        it { dimer_cr.size.should == 7.5 }

        it { ab_ct.size.should == 7.5 }
        it { aib_ct.size.should == 7.84 }
        it { eab_ct.size.should == 8.5 }

        it { hb_ct.size.should == 7.5 }
        it { hib_ct.size.should == 7.84 }
        it { ahb_ct.size.should == 8.5 }
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
        it { ahb_ct.to_s.should == 'H*C%d<' }
        it { hib_ct.to_s.should == 'HC:i%d<' }
      end
    end

  end
end
