require 'spec_helper'

module VersatileDiamond
  module Organizers
    describe AtomProperties, type: :organizer, use: :atom_properties do

      describe 'initialize' do
        describe 'crystal atom with several dependencies' do
          let(:classifier) { AtomClassifier.new }
          let(:dependent_specific_species) do
            [
              dept_activated_bridge,
              dept_activated_incoherent_bridge,
              dept_hydrogenated_incoherent_bridge,
              dept_extra_activated_bridge,
              dept_methyl_on_incoherent_bridge,
              dept_methyl_on_activated_bridge,
              dept_activated_methyl_on_right_bridge,
              dept_activated_dimer,
              dept_activated_methyl_on_bridge,
              dept_activated_methyl_on_incoherent_bridge,
              dept_activated_methyl_on_dimer
            ]
          end

          before do
            organize(dependent_specific_species)
            classifier.analyze(target)
          end

          describe 'activated_methyl_on_dimer' do
            let(:target) { dept_activated_methyl_on_dimer }

            describe '~-C%d< is presented' do
              subject { classifier.index(mod_cr) }
              it { should_not be_nil }
            end

            describe 'classification' do
              subject { classifier.classify(target.parents.first.original) }
              let(:hash) do
                {
                  3 => ['_~-C%d<', 1],
                  4 => ['-C%d<', 1]
                }
              end

              it { should eq(hash) }
            end
          end

          describe 'activated_methyl_on_right_bridge' do
            let(:target) { dept_activated_methyl_on_right_bridge }

            describe '~^C%d< is presented' do
              subject { classifier.index(mob_cb) }
              it { should_not be_nil }
            end
          end
        end

        describe 'first arg is Hash' do
          let(:hash) do
            {
              atom_name: :C,
              valence: 4,
              lattice: diamond,
              relations: [bond_110_cross, bond_110_cross, bond_110_front]
            }
          end

          describe 'all good' do
            it { expect(described_class.new(hash)).to eq(bridge_cr) }
          end

          [:atom_name, :valence, :lattice, :relations].each do |prop|
            describe "without #{prop}" do
              before { hash.delete(prop) }
              it { expect { described_class.new(hash) }.to raise_error RuntimeError }
            end
          end
        end
      end

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

        it { expect(bob).not_to eq(eob) }
        it { expect(eob).not_to eq(bob) }
        it { expect(eob).not_to eq(vob) }
        it { expect(vob).not_to eq(eob) }
      end

      describe '#eql?' do
        it { expect(dimer_cl.eql?(dimer_cr)).to be_truthy }
        it { expect(ab_ct.eql?(aib_ct)).to be_falsey }
      end

      describe '#include?' do
        it { expect(iamob.include?(imob)).to be_truthy }
        it { expect(ihmob.include?(imob)).to be_truthy }
        it { expect(iamob.include?(ihmob)).to be_falsey }
        it { expect(ihmob.include?(iamob)).to be_falsey }
      end

      describe '#contained_in?' do
        it { expect(ucm.contained_in?(high_cm)).to be_falsey }
        it { expect(high_cm.contained_in?(ucm)).to be_falsey }

        it { expect(ucm.contained_in?(bridge_cr)).to be_falsey }
        it { expect(bridge_cr.contained_in?(ucm)).to be_falsey }

        it { expect(bridge_ct.contained_in?(bridge_cr)).to be_truthy }
        it { expect(bridge_ct.contained_in?(dimer_cr)).to be_truthy }
        it { expect(bridge_ct.contained_in?(ab_ct)).to be_truthy }
        it { expect(bridge_ct.contained_in?(aib_ct)).to be_truthy }
        it { expect(bridge_ct.contained_in?(hb_ct)).to be_truthy }

        it { expect(dimer_cr.contained_in?(ad_cr)).to be_truthy }
        it { expect(ad_cr.contained_in?(dimer_cr)).to be_falsey }

        it { expect(ab_ct.contained_in?(ad_cr)).to be_truthy }
        it { expect(ad_cr.contained_in?(ab_ct)).to be_falsey }

        it { expect(ab_ct.contained_in?(eab_ct)).to be_truthy }
        it { expect(eab_ct.contained_in?(ab_ct)).to be_falsey }
        it { expect(hb_ct.contained_in?(ehb_ct)).to be_truthy }
        it { expect(ehb_ct.contained_in?(hb_ct)).to be_falsey }

        it { expect(dimer_cr.contained_in?(bridge_ct)).to be_falsey }
        it { expect(dimer_cr.contained_in?(bridge_cr)).to be_falsey }
        it { expect(ab_ct.contained_in?(bridge_cr)).to be_falsey }
        it { expect(ab_ct.contained_in?(hb_ct)).to be_falsey }
        it { expect(hb_ct.contained_in?(bridge_ct)).to be_falsey }
        it { expect(clb_cr.contained_in?(bridge_cr)).to be_falsey }
        it { expect(clb_cr.contained_in?(hb_cr)).to be_falsey }
        it { expect(bridge_cr.contained_in?(ab_ct)).to be_falsey }
        it { expect(bridge_cr.contained_in?(clb_cr)).to be_truthy }

        it { expect(ab_ct.contained_in?(ahb_ct)).to be_truthy }
        it { expect(hb_ct.contained_in?(ahb_ct)).to be_truthy }
        it { expect(ahb_ct.contained_in?(ab_ct)).to be_falsey }
        it { expect(ahb_ct.contained_in?(hb_ct)).to be_falsey }

        it { expect(ab_ct.contained_in?(aib_ct)).to be_truthy }
        it { expect(aib_ct.contained_in?(ab_ct)).to be_falsey }
        it { expect(hb_ct.contained_in?(hib_ct)).to be_truthy }
        it { expect(hib_ct.contained_in?(hb_ct)).to be_falsey }
        it { expect(bridge_cr.contained_in?(ab_cr)).to be_truthy }
        it { expect(ab_cr.contained_in?(bridge_cr)).to be_falsey }
        it { expect(bridge_cr.contained_in?(hb_cr)).to be_truthy }
        it { expect(hb_cr.contained_in?(bridge_cr)).to be_falsey }
        it { expect(bridge_cr.contained_in?(ib_cr)).to be_truthy }
        it { expect(ib_cr.contained_in?(bridge_cr)).to be_falsey }

        it { expect(aib_ct.contained_in?(ahb_ct)).to be_falsey }
        it { expect(ib_cr.contained_in?(hb_cr)).to be_falsey }
        it { expect(ab_cr.contained_in?(ib_cr)).to be_falsey }
        it { expect(hb_cr.contained_in?(ib_cr)).to be_falsey }
        it { expect(ahb_ct.contained_in?(aib_ct)).to be_falsey }

        it { expect(ucm.contained_in?(cm)).to be_falsey }
        it { expect(eob.contained_in?(cm)).to be_falsey }
        it { expect(vob.contained_in?(cm)).to be_falsey }

        it { expect(cm.contained_in?(ucm)).to be_truthy }
        it { expect(cm.contained_in?(bob)).to be_truthy }
        it { expect(cm.contained_in?(eob)).to be_truthy }
        it { expect(cm.contained_in?(vob)).to be_truthy }

        it { expect(ucm.contained_in?(bob)).to be_falsey }
        it { expect(ucm.contained_in?(eob)).to be_falsey }
        it { expect(ucm.contained_in?(vob)).to be_falsey }
      end

      describe '#same_incoherent?' do
        it { expect(ab_ct.same_incoherent?(ad_cr)).to be_falsey }
        it { expect(ab_ct.same_incoherent?(eab_ct)).to be_falsey }
        it { expect(ab_ct.same_incoherent?(aib_ct)).to be_falsey }
        it { expect(ad_cr.same_incoherent?(ab_ct)).to be_falsey }
        it { expect(eab_ct.same_incoherent?(ab_ct)).to be_falsey }
        it { expect(aib_ct.same_incoherent?(eab_ct)).to be_falsey }
        it { expect(aib_ct.same_incoherent?(ahb_ct)).to be_falsey }
        it { expect(hb_ct.same_incoherent?(ahb_ct)).to be_falsey }
        it { expect(hb_ct.same_incoherent?(hib_ct)).to be_falsey }
        it { expect(hib_ct.same_incoherent?(ahb_ct)).to be_falsey }
        it { expect(hib_ct.same_incoherent?(ehb_ct)).to be_falsey }
        it { expect(ib_cr.same_incoherent?(hb_cr)).to be_falsey }
        it { expect(ib_cr.same_incoherent?(ab_cr)).to be_falsey }
        it { expect(hb_cr.same_incoherent?(ab_cr)).to be_falsey }
        it { expect(ab_cr.same_incoherent?(hb_cr)).to be_falsey }
        it { expect(clb_cr.same_incoherent?(hb_cr)).to be_falsey }

        it { expect(ehb_ct.same_incoherent?(hib_ct)).to be_truthy }
        it { expect(eab_ct.same_incoherent?(aib_ct)).to be_truthy }
        it { expect(ahb_ct.same_incoherent?(hib_ct)).to be_truthy }
        it { expect(ahb_ct.same_incoherent?(aib_ct)).to be_truthy }
        it { expect(hb_cr.same_incoherent?(ib_cr)).to be_truthy }
        it { expect(ab_cr.same_incoherent?(ib_cr)).to be_truthy }
        it { expect(clb_cr.same_incoherent?(ib_cr)).to be_truthy }
      end

      describe '#same_hydrogens?' do
        it { expect(ab_ct.same_hydrogens?(ad_cr)).to be_falsey }
        it { expect(ab_ct.same_hydrogens?(eab_ct)).to be_falsey }
        it { expect(ad_cr.same_hydrogens?(ab_ct)).to be_falsey }
        it { expect(ahb_ct.same_hydrogens?(hib_ct)).to be_falsey }
        it { expect(aib_ct.same_hydrogens?(eab_ct)).to be_falsey }
        it { expect(eab_ct.same_hydrogens?(ab_ct)).to be_falsey }
        it { expect(eab_ct.same_hydrogens?(aib_ct)).to be_falsey }
        it { expect(hb_ct.same_hydrogens?(ahb_ct)).to be_falsey }
        it { expect(hib_ct.same_hydrogens?(ahb_ct)).to be_falsey }
        it { expect(ab_cr.same_hydrogens?(hb_cr)).to be_falsey }
        it { expect(ab_cr.same_hydrogens?(ib_cr)).to be_falsey }
        it { expect(hb_cr.same_hydrogens?(ab_cr)).to be_falsey }
        it { expect(ib_cr.same_hydrogens?(ab_cr)).to be_falsey }
        it { expect(clb_cr.same_hydrogens?(hb_cr)).to be_falsey }

        it { expect(bridge_ct.same_hydrogens?(ehb_ct)).to be_truthy }
        it { expect(bridge_ct.same_hydrogens?(hb_ct)).to be_truthy }
        it { expect(bridge_ct.same_hydrogens?(hib_ct)).to be_truthy }
        it { expect(ab_ct.same_hydrogens?(aib_ct)).to be_truthy }
        it { expect(ahb_ct.same_hydrogens?(aib_ct)).to be_truthy }
        it { expect(aib_ct.same_hydrogens?(ahb_ct)).to be_truthy }
        it { expect(ehb_ct.same_hydrogens?(hib_ct)).to be_truthy }
        it { expect(hb_ct.same_hydrogens?(hib_ct)).to be_truthy }
        it { expect(hib_ct.same_hydrogens?(ehb_ct)).to be_truthy }
        it { expect(hb_cr.same_hydrogens?(ib_cr)).to be_truthy }
        it { expect(clb_cr.same_hydrogens?(ab_cr)).to be_truthy }
        it { expect(ib_cr.same_hydrogens?(hb_cr)).to be_truthy }
      end

      describe '#same_unfixed?' do
        it { expect(cm.same_unfixed?(ucm)).to be_truthy }
        it { expect(cm.same_unfixed?(bob)).to be_falsey }
        it { expect(cm.same_unfixed?(eob)).to be_falsey }
        it { expect(cm.same_unfixed?(vob)).to be_falsey }

        it { expect(ucm.same_unfixed?(cm)).to be_falsey }
        it { expect(ucm.same_unfixed?(bob)).to be_falsey }
        it { expect(ucm.same_unfixed?(eob)).to be_falsey }
        it { expect(ucm.same_unfixed?(vob)).to be_falsey }

        it { expect(bob.same_unfixed?(cm)).to be_falsey }
        it { expect(bob.same_unfixed?(ucm)).to be_falsey }
        it { expect(bob.same_unfixed?(eob)).to be_falsey }
        it { expect(bob.same_unfixed?(vob)).to be_falsey }

        it { expect(eob.same_unfixed?(cm)).to be_falsey }
        it { expect(eob.same_unfixed?(ucm)).to be_truthy }
        it { expect(eob.same_unfixed?(bob)).to be_falsey }
        it { expect(eob.same_unfixed?(vob)).to be_falsey }

        it { expect(vob.same_unfixed?(cm)).to be_falsey }
        it { expect(vob.same_unfixed?(ucm)).to be_truthy }
        it { expect(vob.same_unfixed?(bob)).to be_falsey }
        it { expect(vob.same_unfixed?(eob)).to be_falsey }
      end

      describe '#correspond?' do
        let(:common_info) do
          {
            atom_name: :C,
            valence: 4,
            lattice: diamond
          }
        end

        shared_examples_for :check_that_correspond do
          it { expect(subject.correspond?(info)).to be_truthy }
        end

        it_behaves_like :check_that_correspond do
          subject { bridge_ct }
          let(:relations) { [bond_110_cross, bond_110_cross] }
          let(:info) { common_info.merge(relations: relations) }
        end

        it_behaves_like :check_that_correspond do
          subject { ab_ct }
          let(:relations) { [bond_110_cross, bond_110_cross] }
          let(:danglings) { [active_bond] }
          let(:info) do
            common_info.merge(relations: relations, danglings: danglings)
          end
        end
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
        it { expect(high_cm.incoherent?).to be_falsey }
        it { expect(bridge_ct.incoherent?).to be_falsey }
        it { expect(ab_ct.incoherent?).to be_falsey }
        it { expect(eab_ct.incoherent?).to be_falsey }
        it { expect(ahb_ct.incoherent?).to be_falsey }
        it { expect(hb_ct.incoherent?).to be_falsey }
        it { expect(ehb_ct.incoherent?).to be_falsey }
        it { expect(bridge_cr.incoherent?).to be_falsey }
        it { expect(ab_cr.incoherent?).to be_falsey }
        it { expect(hb_cr.incoherent?).to be_falsey }
        it { expect(clb_cr.incoherent?).to be_falsey }
        it { expect(dimer_cr.incoherent?).to be_falsey }
        it { expect(ad_cr.incoherent?).to be_falsey }

        it { expect(aib_ct.incoherent?).to be_truthy }
        it { expect(hib_ct.incoherent?).to be_truthy }
        it { expect(ib_cr.incoherent?).to be_truthy }
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
        it { expect(high_cm.relevant?).to be_falsey }
        it { expect(bridge_ct.relevant?).to be_falsey }
        it { expect(ad_cr.relevant?).to be_falsey }
        it { expect(eab_ct.relevant?).to be_falsey }
        it { expect(hb_ct.relevant?).to be_falsey }
        it { expect(ehb_ct.relevant?).to be_falsey }
        it { expect(ahb_ct.relevant?).to be_falsey }
        it { expect(clb_cr.relevant?).to be_falsey }

        it { expect(ucm.relevant?).to be_truthy }
        it { expect(aib_ct.relevant?).to be_truthy }
        it { expect(hib_ct.relevant?).to be_truthy }
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
        it { expect(bridge_ct.count_danglings(adsorbed_cl)).to eq(0) }
        it { expect(ib_cr.count_danglings(adsorbed_cl)).to eq(0) }
        it { expect(hb_cr.count_danglings(adsorbed_cl)).to eq(0) }
        it { expect(clb_cr.count_danglings(adsorbed_cl)).to eq(1) }
        it { expect(ad_cr.count_danglings(adsorbed_cl)).to eq(0) }
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

      describe '#unbonded_actives_num' do
        it { expect(bridge_ct.unbonded_actives_num).to eq(2) }
        it { expect(ab_ct.unbonded_actives_num).to eq(3) }
        it { expect(ab_cr.unbonded_actives_num).to eq(4) }
        it { expect(hb_cr.unbonded_actives_num).to eq(3) }
        it { expect(ad_cr.unbonded_actives_num).to eq(4) }
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
        it { expect(ucm.size).to eq(5.05) }
        it { expect(high_cm.size).to eq(6) }

        it { expect(bridge_ct.size).to eq(6.5) }
        it { expect(bridge_cr.size).to eq(7.5) }
        it { expect(dimer_cr.size).to eq(7.5) }

        it { expect(ab_ct.size).to eq(6.84) }
        it { expect(aib_ct.size).to eq(6.97) }
        it { expect(eab_ct.size).to eq(7.18) }

        it { expect(hb_ct.size).to eq(6.84) }
        it { expect(hib_ct.size).to eq(6.97) }
        it { expect(ehb_ct.size).to eq(7.18) }
        it { expect(ahb_ct.size).to eq(7.18) }

        it { expect(ib_cr.size).to eq(7.63) }
        it { expect(ab_cr.size).to eq(7.84) }
        it { expect(hb_cr.size).to eq(7.84) }
        it { expect(clb_cr.size).to eq(7.84) }
      end

      describe '#to_s' do
        it { expect(ucm.to_s).to eq('C:u~%d') }
        it { expect(high_cm.to_s).to eq('C=%d') }

        it { expect(bridge_ct.to_s).to eq('C%d<') }
        it { expect(bridge_cr.to_s).to eq('^C%d<') }
        it { expect(dimer_cr.to_s).to eq('-C%d<') }

        it { expect(ad_cr.to_s).to eq('-*C%d<') }
        it { expect(ab_ct.to_s).to eq('*C%d<') }
        it { expect(aib_ct.to_s).to eq('*C:i%d<') }
        it { expect(eab_ct.to_s).to eq('**C%d<') }

        it { expect(hb_ct.to_s).to eq('HC%d<') }
        it { expect(ehb_ct.to_s).to eq('HHC%d<') }
        it { expect(ahb_ct.to_s).to eq('H*C%d<') }
        it { expect(hib_ct.to_s).to eq('HC:i%d<') }

        it { expect(ab_cr.to_s).to eq('^*C%d<') }
        it { expect(hb_cr.to_s).to eq('^HC%d<') }
        it { expect(ib_cr.to_s).to eq('^C:i%d<') }
      end
    end

  end
end
