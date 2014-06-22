require 'spec_helper'

module VersatileDiamond
  module Generators

    describe EngineCode, use: :engine_generator do
      describe '#specific_gas_species' do
        subject { stub_generator(specific_specs: [methyl, activated_bridge]) }
        let(:gas_specs) { subject.specific_gas_species }
        let(:gas_names) { [:"methane(c: *)", :"hydrogen(h: *)"] }

        before do
          Tools::Config.gas_concentration(methyl, 1, 'mol/l')
          Tools::Config.gas_concentration(hydrogen_ion, 2, 'mol/l')
        end

        it { expect(gas_specs.map(&:name)).to match_array(gas_names) }
      end

      describe '#unique_pure_atoms' do
        let(:bases) { [methane_base, bridge_base] }
        let(:specifics) { [chlorigenated_bridge] }
        subject { stub_generator(base_specs: bases, specific_specs: specifics) }

        it { expect(subject.unique_pure_atoms.map(&:class_name)).to eq(['C']) }
      end
    end

  end
end
