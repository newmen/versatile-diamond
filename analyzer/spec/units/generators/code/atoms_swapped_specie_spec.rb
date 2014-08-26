require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe AtomsSwappedSpecie, use: :engine_generator do
        subject { described_class.new(generator, original_class, 1, 2) }
        let(:original_class) { code_specie.original }
        let(:code_specie) { generator.specie_class(:bridge) }
        let(:generator) do
          stub_generator(base_specs: [dept_bridge_base], specific_specs: [])
        end

        it_behaves_like :all_common_empty_specie_checks

        describe '#base_class_name' do
          let(:base_class_name) { 'AtomsSwapWrapper<Empty<BRIDGE>, 1, 2>' }
          it { expect(subject.base_class_name).to eq(base_class_name) }
        end

        describe 'wrap another empty specie' do
          subject { described_class.new(generator, empty_class, 1, 2) }
          let(:empty_class) do
            ParentsSwappedSpecie.new(generator, original_class, 0, 1)
          end
          let(:code_specie) { generator.specie_class(:dimer) }
          let(:generator) do
            stub_generator(base_specs: [dept_dimer_base], specific_specs: [])
          end

          let(:cap_name) { 'Dimer' }

          it_behaves_like :empty_specie_name_methods
        end
      end

    end
  end
end
