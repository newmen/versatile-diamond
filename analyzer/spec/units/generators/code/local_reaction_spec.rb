require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe LocalReaction, type: :code do
        let(:dept_reaction) { dept_methyl_activation }
        let(:generator) do
          stub_generator(
            ubiquitous_reactions: [dept_surface_activation],
            typical_reactions: [dept_reaction])
        end

        subject { described_class.new(generator, dept_reaction) }
        let(:classifier) { generator.classifier }

        it_behaves_like :check_main_names do
          let(:class_name) { 'ForwardMethylActivation' }
          let(:enum_name) { 'FORWARD_METHYL_ACTIVATION' }
          let(:file_name) { 'forward_methyl_activation' }
          let(:print_name) { methyl_activation.name }
        end

        it_behaves_like :check_gas_concentrations do
          let(:env_concs) { ['Env::cHydrogenHs()'] }
        end

        describe '#base_class_name' do
          it_behaves_like :check_base_class_name do
            let(:outer_class_name) { 'Local' }
            let(:spec) { dept_hydrogenated_methyl_on_bridge }
            let(:cmh_role) { classifier.index(spec, spec.spec.atom(:cm)) }
            let(:templ_args) do
              [
                'ActivationData', 'ForwardSurfaceActivation',
                'FORWARD_METHYL_ACTIVATION', 'METHYL_ON_BRIDGE_CMH', cmh_role
              ]
            end
          end
        end

        describe '#atom_of_complex' do
          let(:atom) { dept_reaction.source.reject(&:simple?).first.atom(:cm) }
          it { expect(subject.atom_of_complex).to eq(atom) }
        end
      end

    end
  end
end
