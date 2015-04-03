require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe CombinedLateralReaction, type: :organizer do
      let(:parent) { dept_dimer_formation }
      let(:ind_chunk) { (ewb_chunk - end_chunk).independent_chunk }
      let(:lat_react) { described_class.new(parent, ind_chunk, 42) }

      describe '#local?' do
        it { expect(lat_react.local?).to be_falsey }
      end

      describe '#lateral?' do
        it { expect(lat_react.lateral?).to be_truthy }
      end

      describe '#parent' do
        it { expect(lat_react.parent).to eq(parent) }
      end

      describe '#chunk' do
        it { expect(lat_react.chunk).to eq(ind_chunk) }
      end

      describe '#full_rate' do
        it { expect(lat_react.full_rate).to eq(42) }
      end

      describe '#each_source' do
        it { expect(lat_react.each_source).to be_a(Enumerator) }

        let(:ab) { dimer_formation.source.first }
        let(:adopted_source) { [ab, ind_chunk.targets.first.first] }
        it { expect(lat_react.each_source.to_a).to match_array(adopted_source) }
      end

      describe '#name' do
        it { expect(lat_react.name).not_to eq(parent.name) }
        it { expect(lat_react.name =~ /^#{parent.name}/).to be_truthy }
      end
    end

  end
end
