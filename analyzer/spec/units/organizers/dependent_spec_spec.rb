require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe DependentSpec, type: :organizer do
      subject { described_class.new(activated_dimer) }

      describe 'default' do
        describe '#reactions state' do
          it { expect(subject.reactions).to be_empty }
        end

        describe '#theres state' do
          it { expect(subject.theres).to be_empty }
        end
      end

      describe '#store_reaction' do
        let(:reaction) { dept_dimer_formation }
        before { subject.store_reaction(reaction) }
        it { expect(subject.reactions).to eq([reaction]) }
      end

      describe '#store_there' do
        let(:there) { dept_on_end }
        before { subject.store_there(there) }
        it { expect(subject.theres).to eq([there]) }
      end
    end

  end
end
