require 'spec_helper'

module VersatileDiamond
  module Mcs

    describe EdgeCache do
      let(:cache) { described_class.new }

      describe "#add and #has?" do
        before(:each) { cache.add(c, n) }

        it { cache.has?(c, n).should be_true }
        it { cache.has?(n, c).should be_true }

        it { cache.has?(c, o).should be_false }
        it { cache.has?(o, c).should be_false }
        it { cache.has?(n, o).should be_false }
        it { cache.has?(o, n).should be_false }
      end
    end

  end
end
