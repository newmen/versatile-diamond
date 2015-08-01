require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe IndependentChunk, type: :organizer do
      let(:ind_bwr) { (mwb_chunk - end_chunk - end_chunk).independent_chunk }
      let(:ind_swr) { (mwb_chunk - middle_chunk).independent_chunk }

      describe '#==' do
        it { expect(ind_bwr).not_to eq(ind_swr) }
        it { expect(ind_swr).not_to eq(ind_bwr) }
      end

      describe '#<=>' do
        it { expect(ind_bwr <=> ind_swr).to eq(0) }
      end

      describe '#same?' do
        it { expect(ind_bwr.same?(ind_swr)).to be_truthy }
        it { expect(ind_swr.same?(ind_bwr)).to be_truthy }
      end

      describe '#replace_target' do
        subject { ind_bwr.replace_target(from, to) }
        let(:from) { ind_bwr.targets.first }
        let(:to) { [extra_activated_bridge, extra_activated_bridge.atom(:ct)] }
        it { expect(subject).to be_a(described_class) }
        it { expect(subject).not_to eq(ind_bwr) }
      end

      describe '#targets' do
        shared_examples_for :check_targets do
          let(:aib) { mwb_lateral_df.source.last }
          let(:targets) { [[aib, aib.atom(:ct)]] }
          it { expect(subject.targets).to be_a(Set) }
          it { expect(subject.targets.to_a).to eq(targets) }
        end

        it_behaves_like :check_targets do
          subject { ind_bwr }
        end

        it_behaves_like :check_targets do
          subject { ind_swr }
        end
      end

      describe '#lateral_reaction' do
        before { dept_mwb_lateral_df.send(:store_parent, dept_dimer_formation) }
        it { expect(ind_bwr.lateral_reaction).to be_a(CombinedLateralReaction) }
        it { expect(ind_bwr.lateral_reaction).to eq(ind_bwr.lateral_reaction) }
      end

      describe '#mapped_targets' do
        it_behaves_like :check_mapped_targets do
          let(:reaction) { dept_mwb_lateral_df }
          let(:chunk) { ind_bwr }
        end
      end

      describe '#parents' do
        it { expect(ind_bwr.parents).to be_empty }
        it { expect(ind_swr.parents).to be_empty }
      end

      describe '#internal_chunks' do
        it { expect(ind_bwr.internal_chunks).to eq([ind_bwr]) }
        it { expect(ind_swr.internal_chunks).to eq([ind_swr]) }
      end

      describe '#tail_name' do
        it { expect(ind_bwr.tail_name).to eq('bridge') }
      end

      describe '#original?' do
        it { expect(ind_bwr.original?).to be_falsey }
      end
    end

  end
end
