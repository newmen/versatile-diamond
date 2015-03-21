require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe UbiquitousReaction do
      let(:already_set) { UbiquitousReaction::AlreadySet }

      %w(enthalpy activation rate temp_power).each do |prop|
        describe "##{prop}" do
          it { expect(surface_deactivation.send(prop)).to eq(0) }
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

      describe '#simple_source' do
        it { expect(surface_activation.simple_source).to eq([hydrogen_ion]) }
        it { expect(surface_deactivation.simple_source).to eq([hydrogen_ion]) }
        it { expect(methyl_activation.simple_source).to eq([hydrogen_ion]) }
        it { expect(methyl_deactivation.simple_source).to eq([hydrogen_ion]) }

        it { expect(dimer_formation.simple_source).to be_empty }
      end

      describe '#simple_products' do
        it { expect(surface_activation.simple_products).to eq([hydrogen]) }
        it { expect(surface_deactivation.simple_products).to be_empty }
        it { expect(methyl_activation.simple_products).to eq([hydrogen]) }
        it { expect(methyl_deactivation.simple_products).to be_empty }
      end

      describe '#reverse' do # it's no use for ubiquitous reaction?
        subject { surface_deactivation.reverse } # synthetics
        it { should be_a(described_class) }

        it { expect(subject.reverse).to eq(surface_deactivation) }
        it { expect(subject.name).to match(/^reverse/) }

        it { expect(subject.source).to eq([adsorbed_h]) }

        it { expect(subject.products).to match_array([active_bond, hydrogen_ion]) }
      end

      describe '#gases_num' do
        it { expect(surface_deactivation.gases_num).to eq(1) }
        it { expect(surface_deactivation.reverse.gases_num).to eq(0) }
        it { expect(surface_activation.gases_num).to eq(1) }
        it { expect(surface_activation.reverse.gases_num).to eq(1) }
      end

      describe '#each_source' do
        let(:collected_source) { surface_deactivation.each_source.to_a }
        it { expect(surface_deactivation.each_source).to be_a(Enumerable) }
        it { expect(collected_source).to match_array([active_bond, hydrogen_ion]) }
      end

      describe '#use_similar_source?' do
        subject { surface_activation }
        it { expect(subject.use_similar_source?(hydrogen_ion)).to be_truthy }
        it { expect(subject.use_similar_source?(hydrogen_ion.dup)).to be_falsey}
        it { expect(subject.use_similar_source?(active_bond)).to be_falsey }
      end

      describe '#swap_source' do
        let(:dup) { hydrogen_ion.dup }
        before(:each) { surface_deactivation.swap_source(hydrogen_ion, dup) }
        it { expect(surface_deactivation.source).to include(dup) }
        it { expect(surface_deactivation.source).not_to include(hydrogen_ion) }
      end

      describe '#same?' do
        let(:same) do
          described_class.new(:forward, 'duplicate', sd_source.shuffle, sd_product)
        end

        it { expect(surface_deactivation.same?(same)).to be_truthy }
        it { expect(same.same?(surface_deactivation)).to be_truthy }

        it { expect(surface_activation.same?(surface_deactivation)).to be_falsey }
        it { expect(surface_deactivation.same?(surface_activation)).to be_falsey }
      end

      describe '#full_rate' do
        before do
          Tools::Config.gas_temperature(1000, 'K')
          Tools::Config.gas_concentration(hydrogen_ion, 0.1, 'mol/cm3')
          surface_deactivation.activation = 1000
          surface_deactivation.rate = 2
        end

        it { expect(surface_deactivation.full_rate.round(10)).to eq(0.1773357811) }
      end

      describe '#changes_num' do
        it { expect(surface_activation.changes_num).to eq(1) }
        it { expect(surface_deactivation.changes_num).to eq(1) }
      end
    end

  end
end
