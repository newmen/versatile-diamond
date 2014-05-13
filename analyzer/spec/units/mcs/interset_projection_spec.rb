require 'spec_helper'

module VersatileDiamond
  module Mcs

    describe IntersecProjection do
      class T; end

      before(:each) { T.extend(described_class) }

      describe '#proj_large' do
        it { expect(T.proj_large([])).to be_empty }
        it { expect(T.proj_large([[1, 2], [3, 4]])).to match_array([1, 3]) }
      end

      describe '#proj_small' do
        it { expect(T.proj_small([])).to be_empty }
        it { expect(T.proj_small([[1, 2], [3, 4]])).to match_array([2, 4]) }
      end
    end

  end
end
