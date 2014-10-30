require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe UbiquitousReaction, type: :code do
        let(:generator) { stub_generator(specific_specs: [dept_hydrogen_ion]) }
        let(:activation_reaction) do
          described_class.new(generator, dept_surface_activation)
        end
        let(:deactivation_reaction) do
          described_class.new(generator, dept_surface_deactivation)
        end

        describe '#base_class_name' do
          it { expect(activation_reaction.base_class_name).
            to eq('ActivationData<FORWARD_SURFACE_ACTIVATION>') }

          it { expect(deactivation_reaction.base_class_name).
            to eq('DeactivationData<FORWARD_SURFACE_DEACTIVATION>') }
        end

        describe '#gas_concentration' do
          let(:hydrogen_env_conc) { 'Env::cHydrogenHs()' }
          it { expect(activation_reaction.gas_concentration).to eq(hydrogen_env_conc) }
          it { expect(deactivation_reaction.gas_concentration).
            to eq(hydrogen_env_conc) }
        end
      end

    end
  end
end
