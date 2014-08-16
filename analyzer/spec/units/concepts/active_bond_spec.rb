require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe ActiveBond, use: :atom_properties do
      it_behaves_like :mono_instance_no_bond do
        subject { active_bond }
      end

      describe '#name' do
        it { expect(active_bond.name).to eq(:*) }
      end

      describe '#external_bonds' do
        it { expect(active_bond.external_bonds).to eq(0) }
      end

      describe '#terminations_num' do
        it { expect(active_bond.terminations_num(hib_ct)).to eq(0) }
        it { expect(active_bond.terminations_num(ab_ct)).to eq(1) }
        it { expect(active_bond.terminations_num(eab_ct)).to eq(2) }
      end

      describe '#apply_to' do
        let(:atom) { SpecificAtom.new(cd) }
        before { subject.apply_to(atom) }
        it { expect(atom.actives).to eq(1) }
      end

      describe '#hydrogen?' do
        it { expect(active_bond.hydrogen?).to be_falsey }
      end

      describe '#same?' do
        it { expect(active_bond.same?(described_class.new)).to be_truthy }
        it { expect(active_bond.same?(adsorbed_h)).to be_falsey }
        it { expect(active_bond.same?(bridge)).to be_falsey }
      end

      describe '#cover?' do
        it { expect(active_bond.cover?(activated_methyl_on_dimer, activated_c)).
          to be_truthy }
        it { expect(active_bond.cover?(
          methyl_on_activated_bridge, methyl_on_activated_bridge.atom(:cb))).
          to be_truthy }
        it { expect(active_bond.cover?(activated_bridge, activated_cd)).
          to be_truthy }
        it { expect(active_bond.cover?(extra_activated_bridge, extra_activated_cd)).
          to be_truthy }
        it { expect(active_bond.cover?(activated_incoherent_bridge, activated_c)).
          to be_truthy }
        it { expect(active_bond.cover?(activated_dimer, activated_cd)).
          to be_truthy }

        it { expect(active_bond.cover?(methyl, c)).to be_falsey }
        it { expect(active_bond.cover?(bridge, cd)).to be_falsey }
        it { expect(active_bond.cover?(chlorigenated_bridge,
          chlorigenated_bridge.atom(:ct))).to be_falsey }
        it { expect(active_bond.cover?(methyl_on_bridge, c)).to be_falsey }
        it { expect(active_bond.cover?(
          activated_incoherent_bridge, incoherent_cd)).
          to be_falsey }
        it { expect(active_bond.cover?(
          activated_methyl_on_dimer, activated_methyl_on_dimer.atom(:cr))).
          to be_falsey }
      end

      it_behaves_like 'termination spec' do
        subject { active_bond }
      end

      it_behaves_like 'visitable' do
        subject { active_bond }
      end
    end

  end
end
