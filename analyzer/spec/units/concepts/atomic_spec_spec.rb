require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe AtomicSpec do
      describe '#name' do
        it { expect(adsorbed_h.name).to eq(:H) }
      end

      describe '#full_name' do
        it { expect(adsorbed_h.full_name).to eq(:H) }
      end

      describe '#external_bonds' do
        it { expect(adsorbed_h.external_bonds).to eq(1) }
      end

      describe '#is_hydrogen?' do
        it { adsorbed_h.is_hydrogen? }
      end

      describe '#same?' do
        it { expect(adsorbed_h.same?(AtomicSpec.new(h.dup))).to be_true }
        it { expect(adsorbed_h.same?(active_bond)).to be_false }
        it { expect(adsorbed_h.same?(bridge)).to be_false }
      end

      describe '#cover?' do
        it { expect(adsorbed_h.cover?(bridge, cd)).to be_true }
        it { expect(adsorbed_h.cover?(activated_bridge, activated_cd)).
          to be_true }
        it { expect(adsorbed_h.cover?(chlorigenated_bridge, cd_chloride)).
          to be_true }
        it { expect(adsorbed_h.cover?(activated_methyl_on_bridge, activated_c)).
          to be_true }
        it { expect(adsorbed_h.cover?(
          activated_methyl_on_bridge, activated_methyl_on_bridge.atom(:cb))).
          to be_true }
        it { expect(adsorbed_h.cover?(
          activated_methyl_on_incoherent_bridge,
          activated_methyl_on_incoherent_bridge.atom(:cb))).
          to be_true }
        it { expect(adsorbed_h.cover?(methyl_on_dimer, methyl_on_dimer.atom(:cm))).
          to be_true }

        it { expect(adsorbed_h.cover?(methane, c)).to be_false }
        it { expect(adsorbed_h.cover?(methyl, activated_c)).to be_false }
        it { expect(adsorbed_h.cover?(extra_activated_bridge, extra_activated_cd)).
          to be_false }
        it { expect(adsorbed_h.cover?(methyl_on_dimer, methyl_on_dimer.atom(:cr))).
          to be_false }

        it { expect(adsorbed_cl.cover?(bridge, bridge.atom(:ct))).to be_false }
        it { expect(adsorbed_cl.cover?(chlorigenated_bridge,cd_chloride)).
          to be_true }
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
