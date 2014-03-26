require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe ActiveBond do
      describe '#name' do
        it { expect(active_bond.name).to eq(:*) }
      end

      describe '#full_name' do
        it { expect(active_bond.full_name).to eq(:*) }
      end

      describe '#external_bonds' do
        it { expect(active_bond.external_bonds).to eq(0) }
      end

      describe '#same?' do
        it { expect(active_bond.same?(ActiveBond.new)).to be_true }
        it { expect(active_bond.same?(adsorbed_h)).to be_false }
        it { expect(active_bond.same?(bridge)).to be_false }
      end

      describe '#cover?' do
        it { expect(active_bond.cover?(activated_methyl_on_dimer, activated_c)).
          to be_true }
        it { expect(active_bond.cover?(
          methyl_on_activated_bridge, methyl_on_activated_bridge.atom(:cb))).
          to be_true }
        it { expect(active_bond.cover?(activated_bridge, activated_cd)).
          to be_true }
        it { expect(active_bond.cover?(extra_activated_bridge, extra_activated_cd)).
          to be_true }
        it { expect(active_bond.cover?(activated_incoherent_bridge, activated_c)).
          to be_true }
        it { expect(active_bond.cover?(activated_dimer, activated_cd)).
          to be_true }

        it { expect(active_bond.cover?(methyl, c)).to be_false }
        it { expect(active_bond.cover?(bridge, cd)).to be_false }
        it { expect(active_bond.cover?(chlorigenated_bridge,
          chlorigenated_bridge.atom(:ct))).to be_false }
        it { expect(active_bond.cover?(methyl_on_bridge, c)).to be_false }
        it { expect(active_bond.cover?(
          activated_incoherent_bridge, incoherent_cd)).
          to be_false }
        it { expect(active_bond.cover?(
          activated_methyl_on_dimer, activated_methyl_on_dimer.atom(:cr))).
          to be_false }
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
