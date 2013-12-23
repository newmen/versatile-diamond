require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe Environment do
      describe "targeting" do
        it { dimers_row.is_target?(:one).should be_true }
        it { dimers_row.is_target?(:two).should be_true }
        it { dimers_row.is_target?(:wrong).should be_false }
      end

      describe "#make_lateral" do
        subject { dimers_row.make_lateral(one: 1, two: 2) }
        it { should be_a(Lateral) }
        it { subject.name.should == :dimers_row }
      end
    end

  end
end
