require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe Specie, use: :engine_generator do
        let(:empty_generator) { stub_generator({}) }

        describe '#class_name' do
          shared_examples_for :check_class_name do
            subject { described_class.new(empty_generator, concept_spec) }
            it { expect(subject.class_name).to eq(class_name) }
          end

          it_behaves_like :check_class_name do
            let(:concept_spec) { hydrogen_ion }
            let(:class_name) { 'HydrogenHs' }
          end

          it_behaves_like :check_class_name do
            let(:concept_spec) { bridge_base }
            let(:class_name) { 'Bridge' }
          end

          it_behaves_like :check_class_name do
            let(:concept_spec) { activated_incoherent_bridge }
            let(:class_name) { 'BridgeCTsi' }
          end

          it_behaves_like :check_class_name do
            let(:concept_spec) { double(name: :'extra_ethane(c1: *, c1: *)') }
            let(:class_name) { 'ExtraEthaneC1ss' }
          end
        end

        describe '#enum_name' do
          shared_examples_for :check_enum_name do
            subject { described_class.new(empty_generator, concept_spec) }
            it { expect(subject.enum_name).to eq(enum_name) }
          end

          it_behaves_like :check_enum_name do
            let(:concept_spec) { bridge_base }
            let(:enum_name) { 'BRIDGE' }
          end

          it_behaves_like :check_enum_name do
            let(:concept_spec) { activated_incoherent_bridge }
            let(:enum_name) { 'BRIDGE_CTsi' }
          end

          it_behaves_like :check_enum_name do
            let(:concept_spec) { double(name: :'bridge_with_dimer(ctb: *)') }
            let(:enum_name) { 'BRIDGE_WITH_DIMER_CTBs' }
          end
        end
      end

    end
  end
end
