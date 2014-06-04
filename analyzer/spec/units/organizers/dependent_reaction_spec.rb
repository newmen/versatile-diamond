require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe DependentReaction do
      def wrap(reaction)
        described_class.new(reaction)
      end

      let(:target) { dimer_formation }
      let(:ai_bridge) { activated_incoherent_bridge }
      let(:duplicate) { wrap(dimer_formation.duplicate('dup')) }

      subject { wrap(target) }

      describe '#complexes' do
        it { expect(subject.complexes).to be_empty }
      end

      describe '#store_complex' do
        let(:complex) { DependentLateralReaction.new(end_lateral_df) }
        before { subject.store_complex(complex) }
        it { expect(subject.complexes).to eq([complex]) }
      end

      describe '#reaction' do
        it { subject.reaction == target }
      end

      describe '#parent' do
        it { expect(subject.parent).to be_nil }
      end

      describe '#name' do
        it { subject.name == target.name }
      end

      describe '#full_rate' do
        it { subject.full_rate == target.full_rate }
      end

      describe '#size' do
        it { subject.size == target.size }
      end

      describe '#each_source' do
        it { expect(subject.each_source).to be_a(Enumerable) }

        it { expect(subject.each_source.to_a).
          to match_array([activated_bridge, ai_bridge]) }

        it { expect(wrap(methyl_deactivation).each_source.to_a).
          to match_array([dm_source.first]) }
      end

      describe '#swap_source' do
        let(:source) { subject.each_source.to_a }
        let(:bridge_dup) { activated_bridge.dup }

        before(:each) { subject.swap_source(activated_bridge, bridge_dup) }

        it { expect(source).to_not include(activated_bridge) }
        it { expect(source).to include(bridge_dup) }
        it { expect(source).to include(ai_bridge) }
      end

      describe '#used_keynames_of' do
        it { expect(subject.used_keynames_of(activated_bridge)).to eq([:ct]) }
        it { expect(subject.used_keynames_of(ai_bridge)).to eq([:ct]) }
      end

      describe '#same?' do
        let(:lateral_subject) do
          DependentLateralReaction.new(
            target.lateral_duplicate('lateral', [on_middle]))
        end

        it { expect(subject.same?(duplicate)).to be_truthy }
        it { expect(duplicate.same?(subject)).to be_truthy }

        it { expect(subject.same?(lateral_subject)).to be_truthy }
        it { expect(lateral_subject.same?(subject)).to be_falsey }

        it { expect(subject.same?(wrap(methyl_deactivation))).to be_falsey }
      end

      describe '#formula' do
        let(:formula) { subject.formula }
        it { expect(formula).to match(/dimer\(.+? i\)/) }
        it { expect(formula).to match(/bridge\(ct: \*\)/) }
        it { expect(formula).to match(/bridge\(ct: \*, ct: i\)/) }
      end
    end

  end
end
