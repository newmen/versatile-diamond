require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe Reaction do
      shared_examples_for "check duplicate" do
        it { subject.name.should =~ /tail$/ }
        it { subject.source.should_not == df_source }
        it { subject.source.first.should_not == df_source.first }
        it { subject.products.should_not == df_products }
        it { subject.products.first.should_not == df_products.first }
        it { subject.products.last.should_not == df_products.last }

        shared_examples_for "both directions" do
          %w(enthalpy activation rate).each do |prop|
            describe "children setup #{prop}" do
              before(:each) do
                child # makes a child
                reaction.send(:"#{prop}=", 456)
              end
              it { child.send(prop).should == 456 }
            end
          end
        end

        it_behaves_like "both directions" do
          let(:reaction) { dimer_formation }
          let(:child) { subject }
        end

        it_behaves_like "both directions" do
          let(:reaction) { dimer_formation.reverse }
          let(:child) { subject.reverse }
        end
      end

      describe "#duplicate" do
        subject { dimer_formation.duplicate('tail') }

        it_behaves_like "check duplicate"
        it { subject.should be_a(described_class) }
      end

      describe "#lateral_duplicate" do
        subject { dimer_formation.lateral_duplicate('tail', [on_end]) }

        it_behaves_like "check duplicate"
        it { subject.should be_a(LateralReaction) }
      end

      describe "#reverse" do
        subject { methyl_desorption.reverse }
        it { should be_a(described_class) }

        it { subject.source.size.should == 2 }
        it { subject.source.should include(methyl, activated_bridge) }

        it { subject.products.should == [methyl_on_bridge] }

        # TODO: need to check reversed atom-mapping result
      end

      describe "#gases_num" do
        it { methyl_desorption.gases_num.should == 0 }
        it { methyl_desorption.reverse.gases_num.should == 1 }

        it { hydrogen_migration.gases_num.should == 0 }
        it { hydrogen_migration.reverse.gases_num.should == 0 }
      end

      describe "#positions" do
        [:one, :two].zip([:first, :last]).each do |l, m|
          let(l) { df_source.send(m).atom(:ct) }
        end

        let(:position) { [one, two, position_front] }
        before(:each) { dimer_formation.positions << position }

        it { dimer_formation.positions.should == [position] }
        it { dimer_formation.reverse.positions.should == [position] }
      end
    end

  end
end
