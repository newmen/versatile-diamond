require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe Reaction do
      [:one, :two].zip([:first, :last]).each do |l, m|
        let(l) { df_source.send(m).atom(:ct) }
      end

      shared_examples_for "check duplicate" do
        it { subject.name.should =~ /tail$/ }
        it { subject.source.should_not == md_source }
        it { subject.source.first.should_not == md_source.first }
        it { subject.products.should_not == md_products }
        it { subject.products.first.should_not == md_products.first }
        it { subject.products.last.should_not == md_products.last }
      end

      describe "#duplicate" do
        subject { methyl_desorption.duplicate('tail') }

        it_behaves_like "check duplicate"
        it { subject.should be_a(described_class) }
      end

      describe "#lateral_duplicate" do
        let(:there) { at_end.concretize(one: one, two: two) }
        subject { methyl_desorption.lateral_duplicate('tail', [there]) }

        it_behaves_like "check duplicate"
        it { subject.should be_a(LateralReaction) }
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

      describe "#positions" do
        let(:position) { [one, two, position_front] }
        before(:each) { dimer_formation.positions << position }

        shared_examples_for "check positions" do
          it { subject.positions.size.should == 1 }
          it { subject.positions.should include(position) }
        end

        it_behaves_like "check positions" do
          subject { dimer_formation }
        end

        it_behaves_like "check positions" do
          subject { dimer_formation.reverse }
        end
      end
    end

  end
end
