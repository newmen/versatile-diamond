require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe AtomicSpec, use: :atom_properties do
      describe 'bond?' do
        it { expect(adsorbed_h.bond?).to be_falsey }
      end

      describe '#name' do
        it { expect(adsorbed_h.name).to eq(:H) }
      end

      describe '#external_bonds' do
        it { expect(adsorbed_h.external_bonds).to eq(1) }
      end

      describe '#hydrogen?' do
        it { adsorbed_h.hydrogen? }
      end

      describe '#terminations_num' do
        it { expect(adsorbed_h.terminations_num(eab_ct)).to eq(0) }
        it { expect(adsorbed_h.terminations_num(ahb_ct)).to eq(1) }
        it { expect(adsorbed_h.terminations_num(ehb_ct)).to eq(2) }
      end

      describe '#== && #same?' do
        [:==, :same?].each do |method|
          it { expect(adsorbed_h.send(method, AtomicSpec.new(h.dup))).to be_truthy }
          it { expect(adsorbed_h.send(method, active_bond)).to be_falsey }
          it { expect(adsorbed_h.send(method, bridge)).to be_falsey }
        end
      end

      describe '#cover?' do
        it { expect(adsorbed_h.cover?(bridge, cd)).to be_truthy }
        it { expect(adsorbed_h.cover?(activated_bridge, activated_cd)).
          to be_truthy }
        it { expect(adsorbed_h.cover?(chlorigenated_bridge, cd_chloride)).
          to be_truthy }
        it { expect(adsorbed_h.cover?(activated_methyl_on_bridge, activated_c)).
          to be_truthy }
        it { expect(adsorbed_h.cover?(
          activated_methyl_on_bridge, activated_methyl_on_bridge.atom(:cb))).
          to be_truthy }
        it { expect(adsorbed_h.cover?(
          activated_methyl_on_incoherent_bridge,
          activated_methyl_on_incoherent_bridge.atom(:cb))).
          to be_truthy }
        it { expect(adsorbed_h.cover?(methyl_on_dimer, methyl_on_dimer.atom(:cm))).
          to be_truthy }

        it { expect(adsorbed_h.cover?(methane, c)).to be_falsey }
        it { expect(adsorbed_h.cover?(methyl, activated_c)).to be_falsey }
        it { expect(adsorbed_h.cover?(extra_activated_bridge, extra_activated_cd)).
          to be_falsey }
        it { expect(adsorbed_h.cover?(methyl_on_dimer, methyl_on_dimer.atom(:cr))).
          to be_falsey }

        it { expect(adsorbed_cl.cover?(bridge, bridge.atom(:ct))).to be_falsey }
        it { expect(adsorbed_cl.cover?(chlorigenated_bridge, cd_chloride)).
          to be_truthy }
      end

      it_behaves_like 'termination spec' do
        subject { adsorbed_h }
      end

      it_behaves_like 'visitable' do
        subject { adsorbed_h }
      end
    end

  end
end
