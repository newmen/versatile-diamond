require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe Reaction do
      describe "#duplicate" do
        subject { methyl_desorption.duplicate('tail') }

        it { subject.name.should =~ /tail$/ }
        it { subject.source.should_not == md_source }
        it { subject.source.first.should_not == md_source.first }
        it { subject.products.should_not == md_products }
        it { subject.products.first.should_not == md_products.first }
        it { subject.products.last.should_not == md_products.last }
      end

      describe "#reverse" do
        subject { methyl_desorption.reverse }

        it { subject.source.size.should == 2 }
        it { subject.source.should include(methyl, activated_bridge) }

        it { subject.products.size.should == 1 }
        it { subject.products.should include(methyl_on_bridge) }

        # TODO: need to check reversed atom-mapping result
      end

      describe "#gases_num" do
        it { methyl_desorption.gases_num.should == 0 }
        it { methyl_desorption.reverse.gases_num.should == 1 }

        it { hydrogen_migration.gases_num.should == 0 }
        it { hydrogen_migration.reverse.gases_num.should == 0 }
      end
    end

  end
end
