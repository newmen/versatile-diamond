require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe AtomicSpec, use: :atom_properties do
      describe '#<=>' do
        it { expect(adsorbed_h <=> adsorbed_h).to eq(0) }
        it { expect(adsorbed_cl <=> adsorbed_h).to eq(-1) }
        it { expect(adsorbed_h <=> adsorbed_cl).to eq(1) }
      end

      describe 'bond?' do
        it { expect(adsorbed_h.bond?).to be_falsey }
      end

      describe '#name' do
        it { expect(adsorbed_h.name).to eq(:H) }
      end

      describe '#external_bonds' do
        it { expect(adsorbed_h.external_bonds).to eq(1) }
      end

      describe '#termination?' do
        it { expect(adsorbed_h.termination?).to be_truthy }
      end

      describe '#hydrogen?' do
        it { expect(adsorbed_h.hydrogen?).to be_truthy }
      end

      describe '#terminations_num' do
        it { expect(adsorbed_h.terminations_num(eab_ct)).to eq(0) }
        it { expect(adsorbed_h.terminations_num(ahb_ct)).to eq(1) }
        it { expect(adsorbed_h.terminations_num(ehb_ct)).to eq(2) }
      end

      describe '#== && #same?' do
        let(:h_dup) { AtomicSpec.new(h.dup) }
        [:==, :same?].each do |method|
          it { expect(adsorbed_h.public_send(method, h_dup)).to be_truthy }
          it { expect(adsorbed_h.public_send(method, active_bond)).to be_falsey }
          it { expect(adsorbed_h.public_send(method, bridge)).to be_falsey }
        end
      end

      describe '#cover?' do
        it { expect(adsorbed_h.cover?(bridge, cd)).to be_truthy }
        it { expect(adsorbed_h.cover?(activated_bridge, activated_cd)).to be_truthy }
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

      it_behaves_like :termination_spec do
        subject { adsorbed_h }
      end
    end

  end
end
