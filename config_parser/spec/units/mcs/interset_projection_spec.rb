require 'spec_helper'

module VersatileDiamond
  module Mcs

    describe IntersetProjection do
      class T; end

      before(:each) { T.extend(described_class) }

      describe "#proj_large" do
        it { T.proj_large([]).should == [] }
        it { T.proj_large([[1, 2], [3, 4]]).should == [1, 3] }
      end

      describe "#proj_small" do
        it { T.proj_small([]).should == [] }
        it { T.proj_small([[1, 2], [3, 4]]).should == [2, 4] }
      end
    end

  end
end
