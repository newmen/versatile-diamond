require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe UbiquitousReaction do
      let(:already_set) { UbiquitousReaction::AlreadySet }

      %w(enthalpy activation rate).each do |prop|
        describe "##{prop}" do
          it { expect(surface_deactivation.send(prop)).to be_nil }
        end

        describe "##{prop}=" do
          it { expect { surface_deactivation.send(:"#{prop}=", 123) }.
            not_to raise_error }
          it 'twise setup' do
            surface_deactivation.send(:"#{prop}=", 123)
            expect { surface_deactivation.send(:"#{prop}=", 987) }.
              to raise_error already_set
          end

          it 'set and get' do
            surface_deactivation.send(:"#{prop}=", 567)
            expect(surface_deactivation.send(prop)).to eq(567)
          end
        end
      end

      describe '#name' do
        it { expect(surface_deactivation.name).to match(/^forward/) }
      end

      describe '#reverse' do # it's no use for ubiquitous reaction?
        subject { surface_deactivation.reverse } # synthetics
        it { should be_a(described_class) }

        it { expect(subject.reverse).to eq(surface_deactivation) }
        it { expect(subject.name).to match(/^reverse/) }

        it { expect(subject.source).to eq([adsorbed_h]) }

        it { expect(subject.products.size).to eq(2) }
        it { expect(subject.products).to include(active_bond, hydrogen_ion) }
      end

      describe '#gases_num' do
        it { expect(surface_deactivation.gases_num).to eq(1) }
        it { expect(surface_deactivation.reverse.gases_num).to eq(0) }
        it { expect(surface_activation.gases_num).to eq(1) }
        it { expect(surface_activation.reverse.gases_num).to eq(1) }
      end

      describe '#each_source' do
        let(:collected_source) do
          surface_deactivation.each_source.with_object([]) do |spec, arr|
            arr << spec
          end
        end
        it { expect(collected_source.size).to eq(2) }
        it { expect(collected_source).to include(active_bond, hydrogen_ion) }
      end

      describe '#swap_source' do
        let(:dup) { hydrogen_ion.dup }
        before(:each) { surface_deactivation.swap_source(hydrogen_ion, dup) }
        it { expect(surface_deactivation.source).to include(dup) }
        it { expect(surface_deactivation.source).not_to include(hydrogen_ion) }
      end

      describe '#same?' do
        let(:same) do
          described_class.new(
            :forward, 'duplicate', sd_source.shuffle, sd_product)
        end

        it { expect(surface_deactivation.same?(same)).to be_true }
        it { expect(same.same?(surface_deactivation)).to be_true }

        it { expect(surface_activation.same?(surface_deactivation)).
          to be_false }
        it { expect(surface_deactivation.same?(surface_activation)).
          to be_false }
      end

      describe '#organize_dependencies! and #more_complex' do
        shared_examples_for 'cover just one' do
          before do
            target.organize_dependencies!(
              [methyl_activation, methyl_deactivation, methyl_desorption,
                dimer_formation, hydrogen_migration])
          end

          it { expect(target.more_complex).to eq([complex]) }
        end

        it_behaves_like 'cover just one' do
          let(:target) { surface_activation }
          let(:complex) { methyl_activation }
        end

        it_behaves_like 'cover just one' do
          let(:target) { surface_deactivation }
          let(:complex) { methyl_deactivation }
        end
      end

      describe '#full_rate' do
        before do
          Tools::Config.gas_temperature(1000, 'K')
          Tools::Config.gas_concentration(hydrogen_ion, 0.1, 'mol/cm3')
          surface_deactivation.activation = 1000
          surface_deactivation.rate = 2
        end

        it { expect(surface_deactivation.full_rate.round(10)).
          to eq(0.1773357811) }
      end

      describe '#size' do
        it { expect(surface_activation.size).to eq(1) }
        it { expect(surface_deactivation.size).to eq(1) }
      end

      describe '#changes_size' do
        it { expect(surface_activation.changes_size).to eq(1) }
        it { expect(surface_deactivation.changes_size).to eq(1) }
      end

      it_behaves_like 'visitable' do
        subject { surface_activation }
      end
    end

  end
end
