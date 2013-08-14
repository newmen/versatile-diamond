require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe Reaction do
      describe "#duplicate" do
        subject { reaction.duplicate('tail') }

        it { subject.name.should =~ /tail$/ }
        it { subject.source.should_not == source }
        it { subject.source.first.should_not == source.first }
        it { subject.products.should_not == products }
        it { subject.products.first.should_not == products.first }
        it { subject.products.last.should_not == products.last }
      end

      describe "#reverse" do
        subject { reaction.reverse }

        it { subject.source.size.should == 2 }
        it { subject.source.should include(methyl, activated_bridge) }

        it { subject.products.size.should == 1 }
        it { subject.products.should include(methyl_on_bridge) }

        # TODO: need to check reversed atom-mapping result
      end

      describe "#gases_num" do
        it { reaction.gases_num.should == 0 }
        it { reaction.reverse.gases_num.should == 1 }
      end
    end

  end
end
