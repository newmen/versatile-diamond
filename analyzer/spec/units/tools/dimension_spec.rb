require 'spec_helper'

module VersatileDiamond
  module Tools

    describe Dimension do

      describe '#convert_temperature' do
        let(:method) { Dimension.method(:convert_temperature) }
        it { expect(method[1, 'K']).to eq(1) }
        it { expect(method[0, 'C']).to eq(273.15) }
        it { expect(method[50, 'F']).to eq(283.15) }

        describe 'with default value' do
          before { Dimension.temperature_dimension('C') }
          it { expect(method[1000]).to eq(1273.15) }
        end
      end

      describe '#convert_concentration' do
        let(:method) { Dimension.method(:convert_concentration) }
        it { expect(method[1, 'mol/mm3']).to eq(1e3) }
        it { expect(method[1, 'mol/cm3']).to eq(1) }
        it { expect(method[1, 'mol/dm3']).to eq(1e-3) }
        it { expect(method[1, 'mol/l']).to eq(1e-3) }
        it { expect(method[1, 'mol/m3']).to eq(1e-6) }
        it { expect(method[1, 'kmol/mm3']).to eq(1e6) }
        it { expect(method[1, 'kmol/cm3']).to eq(1e3) }
        it { expect(method[1, 'kmol/dm3']).to eq(1) }
        it { expect(method[1, 'kmol/l']).to eq(1) }
        it { expect(method[1, 'kmol/m3']).to eq(1e-3) }

        describe 'with default value' do
          before { Dimension.concentration_dimension('mol/l') }
          it { expect(method[2]).to eq(2e-3) }
        end
      end

      describe '#convert_energy' do
        let(:method) { Dimension.method(:convert_energy) }
        it { expect(method[1, 'J/mol']).to eq(1) }
        it { expect(method[1, 'kJ/mol']).to eq(1e3) }
        it { expect(method[1, 'kJ/kmol']).to eq(1) }
        it { expect(method[1, 'kcal/mol']).to eq(4.184e3) }
        it { expect(method[1, 'kcal/kmol']).to eq(4.184) }
        it { expect(method[1, 'cal/mol']).to eq(4.184) }

        describe 'with default value' do
          before { Dimension.energy_dimension('kcal/mol') }
          it { expect(method[2]).to eq(8368) }
        end
      end

      describe '#convert_time' do
        let(:method) { Dimension.method(:convert_time) }
        it { expect(method[1, 's']).to eq(1) }
        it { expect(method[1, 'sec']).to eq(1) }
        it { expect(method[1, 'm']).to eq(60) }
        it { expect(method[1, 'min']).to eq(60) }
        it { expect(method[1, 'h']).to eq(3600) }
        it { expect(method[1, 'hour']).to eq(3600) }

        describe 'with default value' do
          before { Dimension.time_dimension('h') }
          it { expect(method[2]).to eq(7200) }
        end
      end

      describe '#convert_rate' do
        let(:method) { Dimension.method(:convert_rate) }
        it { expect(method[1, 0, '1/s']).to eq(1) }
        it { expect(method[1, 1, 'mm3/(mol * s)']).to eq(1e3) }
        it { expect(method[1, 1, 'cm3/(mol * s)']).to eq(1) }
        it { expect(method[1, 1, 'dm3/(mol * s)']).to eq(1e-3) }
        it { expect(method[1, 1, 'l/(mol * s)']).to eq(1e-3) }
        it { expect(method[1, 1, 'm3/(mol * s)']).to eq(1e-6) }
        it { expect(method[1, 1, 'mm3/(kmol * s)']).to eq(1e6) }
        it { expect(method[1, 1, 'cm3/(kmol * s)']).to eq(1e3) }
        it { expect(method[1, 1, 'dm3/(kmol * s)']).to eq(1) }
        it { expect(method[1, 1, 'l/(kmol * s)']).to eq(1) }
        it { expect(method[1, 1, 'm3/(kmol * s)']).to eq(1e-3) }

        it { expect(method[1, 2, 'cm6/(mol2 * s)']).to eq(1) }
        it { expect(method[1, 2, 'l2/(mol2 * s)']).to eq(1e-6) }
        it { expect(method[1, 3, 'l3/(mol3 * s)']).to eq(1e-9) }

        it { expect(method[1, 2, 'l*l/(mol*mol * s)']).to eq(1e-6) }
        it { expect(method[1, 2, 'l*l/(s * mol2)']).to eq(1e-6) }

        describe 'with default value' do
          before { Dimension.rate_dimension('l/(mol * s)') }
          it { expect(method[2, 1]).to eq(2e-3) }
        end
      end

      describe 'invalid dimenstion value' do
        let(:syntax_error) { Errors::SyntaxError }

        (Dimension::VARIABLES - %w(rate)).each do |var|
          it { expect { Dimension.send("convert_#{var}", 1, 'wtf') }.
            to raise_error syntax_error }
        end

        [
          'l*l/(mol * s)',
          'cm2/(mol * s)',
          'cm3/s',
          's/l',
        ].each do |value|
          it { expect { Dimension.convert_rate(1, 0, value) }.
            to raise_error syntax_error }
        end
      end
    end

  end
end