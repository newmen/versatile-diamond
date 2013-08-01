require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe Named do
      describe "#name" do
        it { Named.new('some').name.should == :some }
      end
    end

  end
end
