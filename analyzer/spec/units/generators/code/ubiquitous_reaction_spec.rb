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

        it_behaves_like :check_main_names do
          subject { activation }
          let(:class_name) { 'ForwardSurfaceActivation' }
          let(:enum_name) { 'FORWARD_SURFACE_ACTIVATION' }
          let(:file_name) { 'forward_surface_activation' }
          let(:print_name) { surface_activation.name }
        end

        describe '#base_class_name' do
          it_behaves_like :check_base_class_name do
            subject { activation }
            let(:outer_class_name) { 'ActivationData' }
            let(:templ_args) { ['FORWARD_SURFACE_ACTIVATION'] }
          end

          it_behaves_like :check_base_class_name do
            subject { deactivation }
            let(:outer_class_name) { 'DeactivationData' }
            let(:templ_args) { ['FORWARD_SURFACE_DEACTIVATION'] }
          end
        end

        describe '#data_class_name' do
          it { expect(activation.data_class_name).to eq('ActivationData') }
          it { expect(deactivation.data_class_name).to eq('DeactivationData') }
        end

        describe '#gas_concentrations' do
          let(:env_concs) { ['Env::cHydrogenHs()'] }

          it_behaves_like :check_gas_concentrations do
            subject { activation }
          end

          it_behaves_like :check_gas_concentrations do
            subject { deactivation }
          end
        end
      end

    end
  end
end
