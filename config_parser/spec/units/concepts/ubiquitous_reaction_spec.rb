require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe UbiquitousReaction do
      let(:source) { [active_bond, hydrogen_ion] }
      let(:product) { [adsorbed_h] }
      let(:reaction) do
        described_class.new(:forward, 'surface deactivation', source, product)
      end

      let(:already_set) { UbiquitousReaction::AlreadySet }

      %w(enthalpy activation rate).each do |prop|
        describe "##{prop}" do
          it { reaction.send(prop).should be_nil }
        end

        describe "##{prop}=" do
          it { expect { reaction.send(:"#{prop}=", 123) }.not_to raise_error }
          it "twise setup" do
            reaction.send(:"#{prop}=", 123)
            expect { reaction.send(:"#{prop}=", 987) }.
              to raise_error already_set
          end

          it "set and get" do
            reaction.send(:"#{prop}=", 567)
            reaction.send(prop).should == 567
          end
        end
      end

      describe "#name" do
        it { reaction.name.should =~ /^forward/ }
      end

      describe "#reverse" do # it's no use for ubiquitous reaction?
        subject { reaction.reverse }
        it { should be_a(described_class) }

        it { subject.reverse.should == reaction }
        it { subject.name.should =~ /^reverse/ }

        it { subject.source.should == [adsorbed_h] }

        it { subject.products.size.should == 2 }
        it { subject.products.should include(active_bond, hydrogen_ion) }
      end

      describe "#gases_num" do
        it { reaction.gases_num.should == 1 }
        it { reaction.reverse.gases_num.should == 0 } # it's no use?
      end

      describe "#each_source" do
        let(:collected_source) do
          reaction.each_source.with_object([]) { |spec, arr| arr << spec }
        end
        it { collected_source.size.should == 2 }
        it { collected_source.should include(active_bond, hydrogen_ion) }
      end

      describe "#full_rate" do
        before do
          Tools::Config.gas_temperature(1000, 'K')
          Tools::Config.gas_concentration(hydrogen_ion, 0.1, 'mol/cm3')
          reaction.activation = 1000
          reaction.rate = 2
        end

        it { reaction.full_rate.round(10).should == 0.1773357811 }
      end
    end

  end
end
