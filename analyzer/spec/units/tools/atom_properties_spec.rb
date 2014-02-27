require 'spec_helper'

module VersatileDiamond
  module Tools
    describe AtomProperties, use: :atom_properties do
      describe "#atom_name" do
        it { bridge_ct.atom_name.should == :C }
      end

      describe "#valence" do
        it { methyl.valence.should == 4 }
        it { c2b.valence.should == 4 }
        it { bridge_ct.valence.should == 4 }
        it { bridge_cr.valence.should == 4 }
        it { ab_ct.valence.should == 4 }
        it { eab_ct.valence.should == 4 }
      end

      describe "#lattice" do
        it { methyl.lattice.should be_nil }
        it { bridge_ct.lattice.should == diamond }
      end

      describe "#relations" do
        it { methyl.relations.should == [free_bond] }
        it { c2b.relations.should == [:dbond] }
        it { bridge_ct.relations.should == [bond_110_cross, bond_110_cross] }
        it { bridge_cr.relations.should == [
            bond_110_cross, bond_110_cross, position_100_front, bond_110_front
          ] }

        it { ad_cr.relations.should == [
            :active, bond_100_front, bond_110_cross, bond_110_cross
          ] }

        it { aib_ct.relations.should == [
            :active, bond_110_cross, bond_110_cross
          ] }

        it { eab_ct.relations.should == [
            :active, :active, bond_110_cross, bond_110_cross
          ] }
      end

      describe "#relevants" do
        it { methyl.relevants.should == [:unfixed] }
        it { c2b.relevants.should be_nil }
        it { bridge_ct.relevants.should be_nil }
        it { ad_cr.relevants.should be_nil }
        it { aib_ct.relevants.should == [:incoherent] }
        it { eab_ct.relevants.should be_nil }
      end

      describe "#==" do
        it { methyl.should_not == c2b }
        it { c2b.should_not == methyl }

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
      end

      describe "#contained_in?" do
        it { methyl.contained_in?(c2b).should be_false }
        it { c2b.contained_in?(methyl).should be_false }

        it { methyl.contained_in?(bridge_cr).should be_false }
        it { bridge_cr.contained_in?(methyl).should be_false }

        it { bridge_ct.contained_in?(bridge_cr).should be_true }
        it { bridge_ct.contained_in?(dimer_cr).should be_true }
        it { bridge_ct.contained_in?(ab_ct).should be_true }
        it { bridge_ct.contained_in?(aib_ct).should be_true }

        it { dimer_cr.contained_in?(ad_cr).should be_true }
        it { ad_cr.contained_in?(dimer_cr).should be_false }

        it { ab_ct.contained_in?(ad_cr).should be_true }
        it { ad_cr.contained_in?(ab_ct).should be_false }

        it { ab_ct.contained_in?(eab_ct).should be_true }
        it { eab_ct.contained_in?(ab_ct).should be_false }

        it { dimer_cr.contained_in?(bridge_ct).should be_false }
        it { dimer_cr.contained_in?(bridge_cr).should be_false }
        it { ab_ct.contained_in?(bridge_cr).should be_false }
        it { bridge_cr.contained_in?(ab_ct).should be_false }
      end

      describe "#same_incoherent?" do
        it { ab_ct.same_incoherent?(ad_cr).should be_false }
        it { ad_cr.same_incoherent?(ab_ct).should be_false }
        it { ab_ct.same_incoherent?(eab_ct).should be_false }
        it { aib_ct.same_incoherent?(eab_ct).should be_false }
        it { eab_ct.same_incoherent?(ab_ct).should be_false }

        it { eab_ct.same_incoherent?(aib_ct).should be_true }
      end

      describe "#terminations_num" do
        it { methyl.terminations_num(active_bond).should == 0 }
        it { methyl.terminations_num(adsorbed_h).should == 3 }

        it { bridge_cr.terminations_num(active_bond).should == 0 }
        it { bridge_cr.terminations_num(adsorbed_h).should == 1 }

        it { ad_cr.terminations_num(active_bond).should == 1 }
        it { ad_cr.terminations_num(adsorbed_h).should == 0 }

        it { eab_ct.terminations_num(active_bond).should == 2 }
        it { eab_ct.terminations_num(adsorbed_h).should == 0 }
      end

      describe "#unrelevanted" do
        it { bridge_ct.unrelevanted.should == bridge_ct }
        it { bridge_ct.should == bridge_ct.unrelevanted }

        it { bridge_ct.should_not == ab_ct.unrelevanted }
        it { ab_ct.unrelevanted.should_not == bridge_ct }

        it { ab_ct.unrelevanted.should == aib_ct.unrelevanted }
        it { aib_ct.unrelevanted.should == ab_ct.unrelevanted }
      end

      describe "#incoherent?" do
        it { c2b.incoherent?.should be_false }
        it { ab_ct.incoherent?.should be_false }
        it { bridge_ct.incoherent?.should be_false }
        it { bridge_cr.incoherent?.should be_false }
        it { dimer_cr.incoherent?.should be_false }
        it { ad_cr.incoherent?.should be_false }
        it { ab_ct.incoherent?.should be_false }
        it { eab_ct.incoherent?.should be_false }

        it { aib_ct.incoherent?.should be_true }
      end

      describe "#incoherent" do
        it { ab_ct.incoherent.should == aib_ct }
        it { aib_ct.incoherent.should be_nil }

        it { bridge_cr.incoherent.should_not be_nil }
        it { bridge_cr.incoherent.should_not == aib_ct }

        it { ad_cr.incoherent.should be_nil }
      end

      describe "#active?" do
        it { bridge_ct.active?.should be_false }
        it { bridge_cr.active?.should be_false }
        it { dimer_cr.active?.should be_false }

        it { ad_cr.active?.should be_true }
        it { ab_ct.active?.should be_true }
        it { aib_ct.active?.should be_true }
      end

      describe "activated" do
        it { bridge_ct.activated.should == ab_ct }
        it { ad_cr.activated.should be_nil }

        it { bridge_cr.activated.activated.should be_nil }
      end

      describe "deactivated" do
        it { bridge_ct.deactivated.should be_nil }
        it { ab_ct.deactivated.should == bridge_ct }

        it { ab_ct.deactivated.deactivated.should be_nil }
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
        it { bridge_ct.size.should == 6.5 }
        it { bridge_cr.size.should == 8.5 }
        it { dimer_cr.size.should == 7.5 }
        it { ab_ct.size.should == 7.5 }
        it { aib_ct.size.should == 7.84 }
      end
    end

  end
end
