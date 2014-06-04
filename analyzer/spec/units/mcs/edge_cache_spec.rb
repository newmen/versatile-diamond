require 'spec_helper'

module VersatileDiamond
  module Mcs

    describe EdgeCache do
      let(:cache) { described_class.new }

      describe '#add and #has?' do
        before(:each) { cache.add(c, n) }

        it { expect(cache.has?(c, n)).to be_truthy }
        it { expect(cache.has?(n, c)).to be_truthy }

        it { expect(cache.has?(c, o)).to be_falsey }
        it { expect(cache.has?(o, c)).to be_falsey }
        it { expect(cache.has?(n, o)).to be_falsey }
        it { expect(cache.has?(o, n)).to be_falsey }
      end
    end

  end
end
