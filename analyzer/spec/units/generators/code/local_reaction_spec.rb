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

        describe '#base_class_name' do
          let(:args) do
            [
              'ActivationData', 'ForwardSurfaceActivation',
              'FORWARD_METHYL_ACTIVATION', 'METHYL_ON_BRIDGE', 0
            ]
          end
          it { expect(subject.base_class_name).to eq("Local<#{args.join(', ')}>") }
        end

        describe '#atom_of_complex' do
          let(:atom) { ma_source.first.atom(:cm) }
          it { expect(subject.atom_of_complex).to eq(atom) }
        end

        describe '#gas_concentrations' do
          let(:hydrogen_env_conc) { ['Env::cHydrogenHs()'] }
          it { expect(subject.gas_concentrations).to eq(hydrogen_env_conc) }
        end
      end

    end
  end
end
