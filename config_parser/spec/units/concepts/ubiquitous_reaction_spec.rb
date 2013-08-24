require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe UbiquitousReaction do
      let(:already_set) { UbiquitousReaction::AlreadySet }

      %w(enthalpy activation rate).each do |prop|
        describe "##{prop}" do
          it { surface_deactivation.send(prop).should be_nil }
        end

        describe "##{prop}=" do
          it { expect { surface_deactivation.send(:"#{prop}=", 123) }.
            not_to raise_error }
          it "twise setup" do
            surface_deactivation.send(:"#{prop}=", 123)
            expect { surface_deactivation.send(:"#{prop}=", 987) }.
              to raise_error already_set
          end

          it "set and get" do
            surface_deactivation.send(:"#{prop}=", 567)
            surface_deactivation.send(prop).should == 567
          end
        end
      end

      describe "#name" do
        it { surface_deactivation.name.should =~ /^forward/ }
      end

      describe "#reverse" do # it's no use for ubiquitous reaction?
        subject { surface_deactivation.reverse } # synthetics
        it { should be_a(described_class) }

        it { subject.reverse.should == surface_deactivation }
        it { subject.name.should =~ /^reverse/ }

        it { subject.source.should == [adsorbed_h] }

        it { subject.products.size.should == 2 }
        it { subject.products.should include(active_bond, hydrogen_ion) }
      end

      describe "#gases_num" do
        it { surface_deactivation.gases_num.should == 1 }
        it { surface_deactivation.reverse.gases_num.should == 0 }
        it { surface_activation.gases_num.should == 1 }
        it { surface_activation.reverse.gases_num.should == 1 }
      end

      describe "#each_source" do
        let(:collected_source) do
          surface_deactivation.each_source.with_object([]) do |spec, arr|
            arr << spec
          end
        end
        it { collected_source.size.should == 2 }
        it { collected_source.should include(active_bond, hydrogen_ion) }
      end

      describe "#swap_source" do
        let(:dup) { hydrogen_ion.dup }
        before(:each) { surface_deactivation.swap_source(hydrogen_ion, dup) }
        it { surface_deactivation.source.should include(dup) }
        it { surface_deactivation.source.should_not include(hydrogen_ion) }
      end

      describe "#same?" do
        let(:same) do
          described_class.new(
            :forward, 'duplicate', sd_source.shuffle, sd_product)
        end

        it { surface_deactivation.same?(same).should be_true }
        it { same.same?(surface_deactivation).should be_true }

        it { surface_activation.same?(surface_deactivation).should be_false }
        it { surface_deactivation.same?(surface_activation).should be_false }
      end

      describe "#organize_dependencies! and #more_complex" do
        shared_examples_for "cover just one" do
          before do
            target.organize_dependencies!(
              [methyl_activation, methyl_deactivation, methyl_desorption,
                dimer_formation, hydrogen_migration])
          end

          it { target.more_complex.should == [complex] }
        end

        it_behaves_like "cover just one" do
          let(:target) { surface_activation }
          let(:complex) { methyl_activation }
        end

        it_behaves_like "cover just one" do
          let(:target) { surface_deactivation }
          let(:complex) { methyl_deactivation }
        end
      end

      describe "#full_rate" do
        before do
          Tools::Config.gas_temperature(1000, 'K')
          Tools::Config.gas_concentration(hydrogen_ion, 0.1, 'mol/cm3')
          surface_deactivation.activation = 1000
          surface_deactivation.rate = 2
        end

        it { surface_deactivation.full_rate.round(10).should == 0.1773357811 }
      end
    end

  end
end
