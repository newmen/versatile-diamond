require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe DependentSpec, type: :organizer do
      subject { described_class.new(activated_dimer) }

      describe '#reactions' do
        it { expect(subject.reactions).to be_empty }
      end

      describe '#store_reaction' do
        let(:reaction) { dept_dimer_formation }
        before { subject.store_reaction(reaction) }
        it { expect(subject.reactions).to eq([reaction]) }
      end
    end

  end
end
