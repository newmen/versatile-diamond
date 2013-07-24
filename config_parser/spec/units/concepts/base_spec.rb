require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe Base do
      describe "#name" do
        it { Base.new('some').name.should == :some }
      end
    end

  end
end
