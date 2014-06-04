require 'spec_helper'

module VersatileDiamond
  module Mcs

    describe SpeciesComparator do
      let(:m) { methane_base }
      let(:br) { bridge_base }
      let(:hb) { high_bridge_base }
      let(:mob) { methyl_on_bridge_base }
      let(:modm) { methyl_on_dimer_base }

      describe '#self.contain?' do
        it { expect(described_class.contain?(mob, br)).to be_truthy }
        it { expect(described_class.contain?(br, mob)).to be_falsey }

        it { expect(described_class.contain?(br, m)).to be_falsey }
        it { expect(described_class.contain?(m, br)).to be_falsey }
        it { expect(described_class.contain?(mob, m)).to be_truthy }
        it { expect(described_class.contain?(m, mob)).to be_falsey }

        it { expect(described_class.contain?(modm, br)).to be_truthy }
        it { expect(described_class.contain?(br, modm)).to be_falsey }
        it { expect(described_class.contain?(modm, mob)).to be_truthy }
        it { expect(described_class.contain?(mob, modm)).to be_falsey }
        it { expect(described_class.contain?(modm, m)).to be_truthy }
        it { expect(described_class.contain?(m, modm)).to be_falsey }

        it { expect(described_class.contain?(hb, mob)).to be_truthy }

        describe 'collaps_multi_bond: true' do
          it { expect(described_class.contain?(
            hb, mob, collaps_multi_bond: true)).to be_falsey }
        end
      end

      describe '#self.intersec' do
        describe 'collaps_multi_bond: false' do
          subject { described_class.intersec(hb, mob).first }

          it { expect(subject.size).to eq(4) }
          it { expect(subject).to include(
              [hb.atom(:cm), mob.atom(:cm)],
              [hb.atom(:cb), mob.atom(:cb)],
              [hb.atom(:cr), mob.atom(:cr)],
              [hb.atom(:cl), mob.atom(:cl)]
            ) }
        end

        describe 'collaps_multi_bond: true' do
          subject do
            described_class.intersec(hb, mob, collaps_multi_bond: true).first
          end

          it { expect(subject.size).to eq(3) }
          it { expect(subject).to include(
              [hb.atom(:cb), mob.atom(:cb)],
              [hb.atom(:cr), mob.atom(:cr)],
              [hb.atom(:cl), mob.atom(:cl)]
            ) }
        end
      end

      describe "#self.first_general_intersec" do
        let(:intersec) do
          described_class.first_general_intersec(bridge_base, bridge_base_dup)
        end
        let(:hash) { Hash[intersec.to_a] }
        it { expect(hash[bridge_base.atom(:ct)]).to eq(bridge_base_dup.atom(:t)) }
      end
    end

  end
end
