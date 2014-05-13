require 'spec_helper'

module VersatileDiamond
  module Organizers
    describe AtomProperties, use: :atom_properties do

      describe '#==' do
        it { expect(ucm).not_to eq(high_cm) }
        it { expect(high_cm).not_to eq(ucm) }

        it { expect(dimer_cl).to eq(dimer_cr) }
        it { expect(dimer_cr).to eq(dimer_cl) }
        it { expect(dimer_cr).to eq(pseudo_dimer_cr) }
        it { expect(pseudo_dimer_cr).to eq(dimer_cr) }

        it { expect(bridge_ct).not_to eq(ab_ct) }
        it { expect(ab_ct).not_to eq(bridge_ct) }

        it { expect(ab_ct).not_to eq(aib_ct) }
        it { expect(aib_ct).not_to eq(ab_ct) }
        it { expect(ab_ct).not_to eq(eab_ct) }
        it { expect(eab_ct).not_to eq(ab_ct) }
        it { expect(eab_ct).not_to eq(aib_ct) }
        it { expect(aib_ct).not_to eq(eab_ct) }

        it { expect(aib_ct).not_to eq(hib_ct) }
        it { expect(hib_ct).not_to eq(aib_ct) }

        it { expect(bridge_cr).not_to eq(hb_cr) }
        it { expect(hb_cr).not_to eq(bridge_cr) }
        it { expect(clb_cr).not_to eq(hb_cr) }

        it { expect(ab_cr).not_to eq(ib_cr) }
        it { expect(hb_cr).not_to eq(ib_cr) }
        it { expect(ib_cr).not_to eq(hb_cr) }
      end

      describe '#contained_in?' do
        it { expect(ucm.contained_in?(high_cm)).to be_false }
        it { expect(high_cm.contained_in?(ucm)).to be_false }

        it { expect(ucm.contained_in?(bridge_cr)).to be_false }
        it { expect(bridge_cr.contained_in?(ucm)).to be_false }

        it { expect(bridge_ct.contained_in?(bridge_cr)).to be_true }
        it { expect(bridge_ct.contained_in?(dimer_cr)).to be_true }
        it { expect(bridge_ct.contained_in?(ab_ct)).to be_true }
        it { expect(bridge_ct.contained_in?(aib_ct)).to be_true }
        it { expect(bridge_ct.contained_in?(hb_ct)).to be_true }

        it { expect(dimer_cr.contained_in?(ad_cr)).to be_true }
        it { expect(ad_cr.contained_in?(dimer_cr)).to be_false }

        it { expect(ab_ct.contained_in?(ad_cr)).to be_true }
        it { expect(ad_cr.contained_in?(ab_ct)).to be_false }

        it { expect(ab_ct.contained_in?(eab_ct)).to be_true }
        it { expect(eab_ct.contained_in?(ab_ct)).to be_false }
        it { expect(hb_ct.contained_in?(ehb_ct)).to be_true }
        it { expect(ehb_ct.contained_in?(hb_ct)).to be_false }

        it { expect(dimer_cr.contained_in?(bridge_ct)).to be_false }
        it { expect(dimer_cr.contained_in?(bridge_cr)).to be_false }
        it { expect(ab_ct.contained_in?(bridge_cr)).to be_false }
        it { expect(ab_ct.contained_in?(hb_ct)).to be_false }
        it { expect(hb_ct.contained_in?(bridge_ct)).to be_false }
        it { expect(clb_cr.contained_in?(bridge_cr)).to be_false }
        it { expect(clb_cr.contained_in?(hb_cr)).to be_false }
        it { expect(bridge_cr.contained_in?(ab_ct)).to be_false }
        it { expect(bridge_cr.contained_in?(clb_cr)).to be_true }

        it { expect(ab_ct.contained_in?(ahb_ct)).to be_true }
        it { expect(hb_ct.contained_in?(ahb_ct)).to be_true }
        it { expect(ahb_ct.contained_in?(ab_ct)).to be_false }
        it { expect(ahb_ct.contained_in?(hb_ct)).to be_false }

        it { expect(ab_ct.contained_in?(aib_ct)).to be_true }
        it { expect(aib_ct.contained_in?(ab_ct)).to be_false }
        it { expect(hb_ct.contained_in?(hib_ct)).to be_true }
        it { expect(hib_ct.contained_in?(hb_ct)).to be_false }
        it { expect(bridge_cr.contained_in?(ab_cr)).to be_true }
        it { expect(ab_cr.contained_in?(bridge_cr)).to be_false }
        it { expect(bridge_cr.contained_in?(hb_cr)).to be_true }
        it { expect(hb_cr.contained_in?(bridge_cr)).to be_false }
        it { expect(bridge_cr.contained_in?(ib_cr)).to be_true }
        it { expect(ib_cr.contained_in?(bridge_cr)).to be_false }

        it { expect(aib_ct.contained_in?(ahb_ct)).to be_false }
        it { expect(ib_cr.contained_in?(hb_cr)).to be_false }
        it { expect(ab_cr.contained_in?(ib_cr)).to be_false }
        it { expect(hb_cr.contained_in?(ib_cr)).to be_false }
        it { expect(ahb_ct.contained_in?(aib_ct)).to be_false }
      end

      describe '#same_incoherent?' do
        it { expect(ab_ct.same_incoherent?(ad_cr)).to be_false }
        it { expect(ab_ct.same_incoherent?(eab_ct)).to be_false }
        it { expect(ab_ct.same_incoherent?(aib_ct)).to be_false }
        it { expect(ad_cr.same_incoherent?(ab_ct)).to be_false }
        it { expect(eab_ct.same_incoherent?(ab_ct)).to be_false }
        it { expect(aib_ct.same_incoherent?(eab_ct)).to be_false }
        it { expect(aib_ct.same_incoherent?(ahb_ct)).to be_false }
        it { expect(hb_ct.same_incoherent?(ahb_ct)).to be_false }
        it { expect(hb_ct.same_incoherent?(hib_ct)).to be_false }
        it { expect(hib_ct.same_incoherent?(ahb_ct)).to be_false }
        it { expect(hib_ct.same_incoherent?(ehb_ct)).to be_false }
        it { expect(ib_cr.same_incoherent?(hb_cr)).to be_false }
        it { expect(ib_cr.same_incoherent?(ab_cr)).to be_false }
        it { expect(hb_cr.same_incoherent?(ab_cr)).to be_false }
        it { expect(ab_cr.same_incoherent?(hb_cr)).to be_false }
        it { expect(clb_cr.same_incoherent?(hb_cr)).to be_false }

        it { expect(ehb_ct.same_incoherent?(hib_ct)).to be_true }
        it { expect(eab_ct.same_incoherent?(aib_ct)).to be_true }
        it { expect(ahb_ct.same_incoherent?(hib_ct)).to be_true }
        it { expect(ahb_ct.same_incoherent?(aib_ct)).to be_true }
        it { expect(hb_cr.same_incoherent?(ib_cr)).to be_true }
        it { expect(ab_cr.same_incoherent?(ib_cr)).to be_true }
        it { expect(clb_cr.same_incoherent?(ib_cr)).to be_true }
      end

      describe '#same_hydrogens?' do
        it { expect(ab_ct.same_hydrogens?(ad_cr)).to be_false }
        it { expect(ab_ct.same_hydrogens?(eab_ct)).to be_false }
        it { expect(ad_cr.same_hydrogens?(ab_ct)).to be_false }
        it { expect(ahb_ct.same_hydrogens?(hib_ct)).to be_false }
        it { expect(aib_ct.same_hydrogens?(eab_ct)).to be_false }
        it { expect(eab_ct.same_hydrogens?(ab_ct)).to be_false }
        it { expect(eab_ct.same_hydrogens?(aib_ct)).to be_false }
        it { expect(hb_ct.same_hydrogens?(ahb_ct)).to be_false }
        it { expect(hib_ct.same_hydrogens?(ahb_ct)).to be_false }
        it { expect(ab_cr.same_hydrogens?(hb_cr)).to be_false }
        it { expect(ab_cr.same_hydrogens?(ib_cr)).to be_false }
        it { expect(hb_cr.same_hydrogens?(ab_cr)).to be_false }
        it { expect(ib_cr.same_hydrogens?(ab_cr)).to be_false }
        it { expect(clb_cr.same_hydrogens?(hb_cr)).to be_false }

        it { expect(bridge_ct.same_hydrogens?(ehb_ct)).to be_true }
        it { expect(bridge_ct.same_hydrogens?(hb_ct)).to be_true }
        it { expect(bridge_ct.same_hydrogens?(hib_ct)).to be_true }
        it { expect(ab_ct.same_hydrogens?(aib_ct)).to be_true }
        it { expect(ahb_ct.same_hydrogens?(aib_ct)).to be_true }
        it { expect(aib_ct.same_hydrogens?(ahb_ct)).to be_true }
        it { expect(ehb_ct.same_hydrogens?(hib_ct)).to be_true }
        it { expect(hb_ct.same_hydrogens?(hib_ct)).to be_true }
        it { expect(hib_ct.same_hydrogens?(ehb_ct)).to be_true }
        it { expect(hb_cr.same_hydrogens?(ib_cr)).to be_true }
        it { expect(clb_cr.same_hydrogens?(ab_cr)).to be_true }
        it { expect(ib_cr.same_hydrogens?(hb_cr)).to be_true }
      end

      describe '#unrelevanted' do
        it { expect(bridge_ct.unrelevanted).to eq(bridge_ct) }
        it { expect(bridge_ct).to eq(bridge_ct.unrelevanted) }

        it { expect(bridge_ct).not_to eq(ab_ct.unrelevanted) }
        it { expect(ab_ct.unrelevanted).not_to eq(bridge_ct) }

        it { expect(aib_ct.unrelevanted).to eq(ab_ct) }
        it { expect(hib_ct.unrelevanted).to eq(hb_ct) }

        it { expect(ib_cr.unrelevanted).to eq(bridge_cr) }
        it { expect(ab_cr.unrelevanted).to eq(ab_cr) }
        it { expect(hb_cr.unrelevanted).to eq(hb_cr) }
        it { expect(clb_cr.unrelevanted).to eq(clb_cr) }
      end

      describe '#incoherent?' do
        it { expect(high_cm.incoherent?).to be_false }
        it { expect(bridge_ct.incoherent?).to be_false }
        it { expect(ab_ct.incoherent?).to be_false }
        it { expect(eab_ct.incoherent?).to be_false }
        it { expect(ahb_ct.incoherent?).to be_false }
        it { expect(hb_ct.incoherent?).to be_false }
        it { expect(ehb_ct.incoherent?).to be_false }
        it { expect(bridge_cr.incoherent?).to be_false }
        it { expect(ab_cr.incoherent?).to be_false }
        it { expect(hb_cr.incoherent?).to be_false }
        it { expect(clb_cr.incoherent?).to be_false }
        it { expect(dimer_cr.incoherent?).to be_false }
        it { expect(ad_cr.incoherent?).to be_false }

        it { expect(aib_ct.incoherent?).to be_true }
        it { expect(hib_ct.incoherent?).to be_true }
        it { expect(ib_cr.incoherent?).to be_true }
      end

      describe '#incoherent' do
        it { expect(ucm.incoherent).not_to be_nil }
        it { expect(high_cm.incoherent).not_to be_nil }

        it { expect(ab_ct.incoherent).to eq(aib_ct) }
        it { expect(aib_ct.incoherent).to be_nil }
        it { expect(eab_ct.incoherent).to be_nil }

        it { expect(bridge_cr.incoherent).not_to be_nil }
        it { expect(bridge_cr.incoherent).not_to eq(aib_ct) }

        it { expect(ad_cr.incoherent).to be_nil }

        it { expect(hb_ct.incoherent).to eq(hib_ct) }
        it { expect(hib_ct.incoherent).to be_nil }
        it { expect(ahb_ct.incoherent).to be_nil }
        it { expect(ehb_ct.incoherent).to be_nil }

        it { expect(ab_cr.incoherent).to be_nil }
        it { expect(hb_cr.incoherent).to be_nil }
        it { expect(ib_cr.incoherent).to be_nil }
      end

      describe '#relevant?' do
        it { expect(high_cm.relevant?).to be_false }
        it { expect(bridge_ct.relevant?).to be_false }
        it { expect(ad_cr.relevant?).to be_false }
        it { expect(eab_ct.relevant?).to be_false }
        it { expect(hb_ct.relevant?).to be_false }
        it { expect(ehb_ct.relevant?).to be_false }
        it { expect(ahb_ct.relevant?).to be_false }
        it { expect(clb_cr.relevant?).to be_false }

        it { expect(ucm.relevant?).to be_true }
        it { expect(aib_ct.relevant?).to be_true }
        it { expect(hib_ct.relevant?).to be_true }
      end

      describe 'activated' do
        it { expect(ucm.activated).not_to be_nil }
        it { expect(high_cm.activated).not_to be_nil }

        it { expect(bridge_ct.activated).to eq(ab_ct) }
        it { expect(ab_ct.activated).to eq(eab_ct) }
        it { expect(eab_ct.activated).to be_nil }
        it { expect(ad_cr.activated).to be_nil }

        it { expect(bridge_cr.activated.activated).to be_nil }

        it { expect(hb_ct.activated).to eq(ahb_ct) }
        it { expect(ehb_ct.activated).to be_nil }
        it { expect(ahb_ct.activated).to be_nil }

        it { expect(ab_cr.activated).to be_nil }
        it { expect(hb_cr.activated).to be_nil }
        it { expect(ib_cr.activated).not_to be_nil }
      end

      describe 'deactivated' do
        it { expect(ucm.deactivated).to be_nil }
        it { expect(high_cm.deactivated).to be_nil }

        it { expect(bridge_ct.deactivated).to be_nil }
        it { expect(ab_ct.deactivated).to eq(bridge_ct) }
        it { expect(eab_ct.deactivated).to eq(ab_ct) }

        it { expect(ab_ct.deactivated.deactivated).to be_nil }

        it { expect(ahb_ct.deactivated).to eq(hb_ct) }
        it { expect(ab_cr.deactivated).to eq(bridge_cr) }

        it { expect(hb_ct.deactivated).to be_nil }
        it { expect(ehb_ct.deactivated).to be_nil }
        it { expect(hb_cr.deactivated).to be_nil }
        it { expect(ib_cr.deactivated).to be_nil }
      end

      describe '#count_danglings' do
        it { expect(bridge_ct.count_danglings(:Cl)).to eq(0) }
        it { expect(ib_cr.count_danglings(:Cl)).to eq(0) }
        it { expect(hb_cr.count_danglings(:Cl)).to eq(0) }
        it { expect(clb_cr.count_danglings(:Cl)).to eq(1) }
        it { expect(ad_cr.count_danglings(:Cl)).to eq(0) }
      end

      describe '#actives_num' do
        it { expect(bridge_ct.actives_num).to eq(0) }
        it { expect(ab_ct.actives_num).to eq(1) }
        it { expect(ahb_ct.actives_num).to eq(1) }
        it { expect(aib_ct.actives_num).to eq(1) }
        it { expect(eab_ct.actives_num).to eq(2) }
        it { expect(ehb_ct.actives_num).to eq(0) }
        it { expect(hb_ct.actives_num).to eq(0) }
        it { expect(hib_ct.actives_num).to eq(0) }
        it { expect(ib_cr.actives_num).to eq(0) }
        it { expect(ab_cr.actives_num).to eq(1) }
        it { expect(hb_cr.actives_num).to eq(0) }
        it { expect(clb_cr.actives_num).to eq(0) }
        it { expect(ad_cr.actives_num).to eq(1) }
      end

      describe '#dangling_hydrogens_num' do
        it { expect(bridge_ct.dangling_hydrogens_num).to eq(0) }
        it { expect(ab_ct.dangling_hydrogens_num).to eq(0) }
        it { expect(ahb_ct.dangling_hydrogens_num).to eq(1) }
        it { expect(aib_ct.dangling_hydrogens_num).to eq(0) }
        it { expect(eab_ct.dangling_hydrogens_num).to eq(0) }
        it { expect(ehb_ct.dangling_hydrogens_num).to eq(2) }
        it { expect(hb_ct.dangling_hydrogens_num).to eq(1) }
        it { expect(hib_ct.dangling_hydrogens_num).to eq(1) }
        it { expect(ib_cr.dangling_hydrogens_num).to eq(0) }
        it { expect(ab_cr.dangling_hydrogens_num).to eq(0) }
        it { expect(hb_cr.dangling_hydrogens_num).to eq(1) }
        it { expect(clb_cr.dangling_hydrogens_num).to eq(0) }
        it { expect(ad_cr.dangling_hydrogens_num).to eq(0) }
      end

      describe '#total_hydrogens_num' do
        it { expect(bridge_ct.total_hydrogens_num).to eq(2) }
        it { expect(ab_ct.total_hydrogens_num).to eq(1) }
        it { expect(ahb_ct.total_hydrogens_num).to eq(1) }
        it { expect(aib_ct.total_hydrogens_num).to eq(1) }
        it { expect(eab_ct.total_hydrogens_num).to eq(0) }
        it { expect(ehb_ct.total_hydrogens_num).to eq(2) }
        it { expect(hb_ct.total_hydrogens_num).to eq(2) }
        it { expect(hib_ct.total_hydrogens_num).to eq(2) }
        it { expect(ib_cr.total_hydrogens_num).to eq(1) }
        it { expect(ab_cr.total_hydrogens_num).to eq(0) }
        it { expect(hb_cr.total_hydrogens_num).to eq(1) }
        it { expect(clb_cr.total_hydrogens_num).to eq(0) }
        it { expect(ad_cr.total_hydrogens_num).to eq(0) }
      end

      describe '#smallests' do
        it { expect(bridge_ct.smallests).to be_nil }
        it { expect(ab_ct.smallests).to be_nil }

        describe '#add_smallest' do
          before(:each) { ab_ct.add_smallest(bridge_ct) }
          it { expect(bridge_ct.smallests).to be_nil }
          it { expect(ab_ct.smallests.to_a).to eq([bridge_ct]) }
        end
      end

      describe '#sames' do
        it { expect(aib_ct.sames).to be_nil }
        it { expect(eab_ct.sames).to be_nil }

        describe '#add_same' do
          before(:each) { eab_ct.add_same(aib_ct) }
          it { expect(aib_ct.sames).to be_nil }
          it { expect(eab_ct.sames.to_a).to eq([aib_ct]) }
        end
      end

      describe '#size' do
        it { expect(ucm.size).to eq(5.13) }
        it { expect(high_cm.size).to eq(6) }

        it { expect(bridge_ct.size).to eq(6.5) }
        it { expect(bridge_cr.size).to eq(8.5) }
        it { expect(dimer_cr.size).to eq(7.5) }

        it { expect(ab_ct.size).to eq(6.84) }
        it { expect(aib_ct.size).to eq(6.97) }
        it { expect(eab_ct.size).to eq(7.18) }

        it { expect(hb_ct.size).to eq(6.84) }
        it { expect(hib_ct.size).to eq(6.97) }
        it { expect(ehb_ct.size).to eq(7.18) }
        it { expect(ahb_ct.size).to eq(7.18) }

        it { expect(ib_cr.size).to eq(8.63) }
        it { expect(ab_cr.size).to eq(8.84) }
        it { expect(hb_cr.size).to eq(8.84) }
        it { expect(clb_cr.size).to eq(8.84) }
      end

      describe '#to_s' do
        it { expect(ucm.to_s).to eq('C:u~') }
        it { expect(high_cm.to_s).to eq('C=') }

        it { expect(bridge_ct.to_s).to eq('C%d<') }
        it { expect(bridge_cr.to_s).to eq('^C.%d<') }
        it { expect(dimer_cr.to_s).to eq('-C%d<') }

        it { expect(ad_cr.to_s).to eq('-*C%d<') }
        it { expect(ab_ct.to_s).to eq('*C%d<') }
        it { expect(aib_ct.to_s).to eq('*C:i%d<') }
        it { expect(eab_ct.to_s).to eq('**C%d<') }

        it { expect(hb_ct.to_s).to eq('HC%d<') }
        it { expect(ehb_ct.to_s).to eq('HHC%d<') }
        it { expect(ahb_ct.to_s).to eq('H*C%d<') }
        it { expect(hib_ct.to_s).to eq('HC:i%d<') }

        it { expect(ab_cr.to_s).to eq('^*C.%d<') }
        it { expect(hb_cr.to_s).to eq('^HC.%d<') }
        it { expect(ib_cr.to_s).to eq('^C.:i%d<') }
      end
    end

  end
end
