require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe UbiquitousReaction, type: :code do
        let(:generator) { stub_generator(specific_specs: [dept_hydrogen_ion]) }
        let(:activation) { described_class.new(generator, dept_surface_activation) }
        let(:deactivation) do
          described_class.new(generator, dept_surface_deactivation)
        end

        describe '#base_class_name' do
          it { expect(activation.base_class_name).
            to eq('ActivationData<FORWARD_SURFACE_ACTIVATION>') }

          it { expect(deactivation.base_class_name).
            to eq('DeactivationData<FORWARD_SURFACE_DEACTIVATION>') }
        end

        describe '#data_class_name' do
          it { expect(activation.data_class_name).to eq('ActivationData') }
          it { expect(deactivation.data_class_name).to eq('DeactivationData') }
        end

        describe '#gas_concentrations' do
          let(:hydrogen_env_conc) { ['Env::cHydrogenHs()'] }
          it { expect(activation.gas_concentrations).to eq(hydrogen_env_conc) }
          it { expect(deactivation.gas_concentrations).to eq(hydrogen_env_conc) }
        end
      end

    end
  end
end
