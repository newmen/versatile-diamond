require 'spec_helper'

module VersatileDiamond
  module Mcs

    describe EdgeCache do
      let(:cache) { described_class.new }

      describe '#add and #has?' do
        before(:each) { cache.add(c, n) }

        it { expect(cache.has?(c, n)).to be_true }
        it { expect(cache.has?(n, c)).to be_true }

        it { expect(cache.has?(c, o)).to be_false }
        it { expect(cache.has?(o, c)).to be_false }
        it { expect(cache.has?(n, o)).to be_false }
        it { expect(cache.has?(o, n)).to be_false }
      end
    end

  end
end
