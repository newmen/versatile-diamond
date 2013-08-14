require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe UbiquitousReaction do
      let(:source) { [active_bond, hydrogen_ion] }
      let(:product) { [adsorbed_h] }
      let(:reaction) do
        described_class.new('surface deactivation', source, product)
      end

      let(:already_set) { UbiquitousReaction::AlreadySet }

      %w(enthalpy activation rate).each do |prop|
        describe "##{prop}=" do
          it { expect { reaction.send(:"#{prop}=", 123) }.not_to raise_error }
          it "twise setup" do
            reaction.send(:"#{prop}=", 123)
            expect { reaction.send(:"#{prop}=", 987) }.
              to raise_error already_set
          end
        end
      end

      describe "#reverse" do # it's no use for ubiquitous reaction?
        subject { reaction.reverse }

        it { subject.source.size.should == 1 }
        it { subject.source.should include(adsorbed_h) }

        it { subject.products.size.should == 2 }
        it { subject.products.should include(active_bond, hydrogen_ion) }
      end

      describe "#gases_num" do
        it { reaction.gases_num.should == 1 }
        it { reaction.reverse.gases_num.should == 0 } # it's no use
      end
    end

  end
end
