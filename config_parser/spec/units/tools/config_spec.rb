require 'spec_helper'

module VersatileDiamond
  module Tools

    describe Config do
      let(:error) { described_class::AlreadyDefined }

      describe "#total_time" do
        it "duplicating" do
          described_class.total_time(1, 'sec')
          expect { described_class.total_time(12, 'sec') }.to raise_error error
        end
      end

      describe "#gas_concentration" do
        it "duplicating" do
          described_class.gas_concentration(methyl, 1e-3, 'mol/l')
          expect { described_class.gas_concentration(methyl, 1e-5, 'mol/l') }.
            to raise_error error
        end
      end

      describe "#surface_composition" do
        it "duplicating" do
          described_class.surface_composition(cd)
          expect { described_class.surface_composition(cd) }.
            to raise_error error
        end
      end

      %w(gas surface).each do |type|
        name = "#{type}_temperature"
        describe "##{name}" do
          it "duplicating" do
            described_class.send(name, 1000, 'C')
            expect { described_class.send(name, 373, 'K') }.
              to raise_error error
          end
        end
      end

      describe "#current_temperature" do
        before(:each) do
          described_class.gas_temperature(100, 'K')
          described_class.surface_temperature(0, 'K')
        end

        it { described_class.current_temperature(1).should == 100 }
        it { described_class.current_temperature(0).should == 0 }
      end

      describe "#rate" do
        before do
          methyl_desorption.activation = 1
          methyl_desorption.rate = 1
          described_class.surface_temperature(300, 'K')
        end

        it { described_class.rate(methyl_desorption).round(10).
          should == 0.9995991725 }
      end
    end

  end
end
