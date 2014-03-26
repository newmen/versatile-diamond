require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe Environment do
      describe 'targeting' do
        it { expect(dimers_row.target?(:one)).to be_true }
        it { expect(dimers_row.target?(:two)).to be_true }
        it { expect(dimers_row.target?(:wrong)).to be_false }
      end

      describe '#make_lateral' do
        subject { dimers_row.make_lateral(one: 1, two: 2) }
        it { should be_a(Lateral) }
        it { expect(subject.name).to eq(:dimers_row) }
      end
    end

  end
end
