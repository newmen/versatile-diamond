require 'spec_helper'

module VersatileDiamond
  module Tools

    describe Dimension do

      describe "#convert_temperature" do
        let(:method) { Dimension.method(:convert_temperature) }
        it { method[1, 'K'].should == 1 }
        it { method[0, 'C'].should == 273.15 }
        it { method[50, 'F'].should == 283.15 }

        describe "with default value" do
          before { Dimension.temperature_dimension('C') }
          it { method[1000].should == 1273.15 }
        end
      end

      describe "#convert_concentration" do
        let(:method) { Dimension.method(:convert_concentration) }
        it { method[1, 'mol/mm3'].should == 1e3 }
        it { method[1, 'mol/cm3'].should == 1 }
        it { method[1, 'mol/dm3'].should == 1e-3 }
        it { method[1, 'mol/l'].should == 1e-3 }
        it { method[1, 'mol/m3'].should == 1e-6 }
        it { method[1, 'kmol/mm3'].should == 1e6 }
        it { method[1, 'kmol/cm3'].should == 1e3 }
        it { method[1, 'kmol/dm3'].should == 1 }
        it { method[1, 'kmol/l'].should == 1 }
        it { method[1, 'kmol/m3'].should == 1e-3 }

        describe "with default value" do
          before { Dimension.concentration_dimension('mol/l') }
          it { method[2].should == 2e-3 }
        end
      end

      describe "#convert_energy" do
        let(:method) { Dimension.method(:convert_energy) }
        it { method[1, 'J/mol'].should == 1 }
        it { method[1, 'kJ/mol'].should == 1e3 }
        it { method[1, 'kJ/kmol'].should == 1 }
        it { method[1, 'kcal/mol'].should == 4.184e3 }
        it { method[1, 'kcal/kmol'].should == 4.184 }
        it { method[1, 'cal/mol'].should == 4.184 }

        describe "with default value" do
          before { Dimension.energy_dimension('kcal/mol') }
          it { method[2].should == 8368 }
        end
      end

      describe "#convert_time" do
        let(:method) { Dimension.method(:convert_time) }
        it { method[1, 's'].should == 1 }
        it { method[1, 'sec'].should == 1 }
        it { method[1, 'm'].should == 60 }
        it { method[1, 'min'].should == 60 }
        it { method[1, 'h'].should == 3600 }
        it { method[1, 'hour'].should == 3600 }

        describe "with default value" do
          before { Dimension.time_dimension('h') }
          it { method[2].should == 7200 }
        end
      end

      describe "#convert_rate" do
        let(:method) { Dimension.method(:convert_rate) }
        it { method[1, 0, '1/s'].should == 1 }
        it { method[1, 1, 'mm3/(mol * s)'].should == 1e3 }
        it { method[1, 1, 'cm3/(mol * s)'].should == 1 }
        it { method[1, 1, 'dm3/(mol * s)'].should == 1e-3 }
        it { method[1, 1, 'l/(mol * s)'].should == 1e-3 }
        it { method[1, 1, 'm3/(mol * s)'].should == 1e-6 }
        it { method[1, 1, 'mm3/(kmol * s)'].should == 1e6 }
        it { method[1, 1, 'cm3/(kmol * s)'].should == 1e3 }
        it { method[1, 1, 'dm3/(kmol * s)'].should == 1 }
        it { method[1, 1, 'l/(kmol * s)'].should == 1 }
        it { method[1, 1, 'm3/(kmol * s)'].should == 1e-3 }

        it { method[1, 2, 'cm6/(mol2 * s)'].should == 1 }
        it { method[1, 2, 'l2/(mol2 * s)'].should == 1e-6 }
        it { method[1, 3, 'l3/(mol3 * s)'].should == 1e-9 }

        it { method[1, 2, 'l*l/(mol*mol * s)'].should == 1e-6 }
        it { method[1, 2, 'l*l/(s * mol2)'].should == 1e-6 }

        describe "with default value" do
          before { Dimension.rate_dimension('l/(mol * s)') }
          it { method[2, 1].should == 2e-3 }
        end
      end

      describe "invalid dimenstion value" do
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