require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe DependentLateralReaction, type: :organizer do
      subject { dept_middle_lateral_df }

      describe '#sidepiece_specs' do
        it { expect(subject.sidepiece_specs.map(&:name)).to eq([:'dimer()'] * 2) }
      end

      describe '#chunk' do
        it { expect(subject.chunk.same?(middle_chunk)).to be_truthy }
      end

      describe '#theres' do
        it { expect(subject.theres.first).to be_a(DependentThere) }

        describe 'internal caching' do
          it { expect(subject.theres).to eq(subject.theres) }
        end
      end

      describe '#lateral?' do
        it { expect(subject.lateral?).to be_truthy }
      end
    end

  end
end
