require 'spec_helper'

module VersatileDiamond
  module Tools

    describe Config do
      let(:error) { Config::AlreadyDefined }

      describe "#total_time" do
        it "duplicating" do
          Config.total_time(1, 'sec')
          expect { Config.total_time(12, 'sec') }.to raise_error error
        end
      end

      describe "#gas_concentration" do
        it "duplicating" do
          Config.gas_concentration(methyl, 1e-3, 'mol/l')
          expect { Config.gas_concentration(methyl, 1e-5, 'mol/l') }.
            to raise_error error
        end
      end

      describe "#surface_composition" do
        it "duplicating" do
          Config.surface_composition(cd)
          expect { Config.surface_composition(cd) }.to raise_error error
        end
      end

      %w(gas surface).each do |type|
        name = "#{type}_temperature"
        describe "##{name}" do
          it "duplicating" do
            Config.send(name, 1000, 'C')
            expect { Config.send(name, 373, 'K') }.to raise_error error
          end
        end
      end

      describe "#current_temperature" do
        before(:each) do
          Config.gas_temperature(100, 'K')
          Config.surface_temperature(0, 'K')
        end

        it { Config.current_temperature(1).should == 100 }
        it { Config.current_temperature(0).should == 0 }
      end
    end

  end
end
