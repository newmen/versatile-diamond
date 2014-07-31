require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe ParentsSwappedSpecie, use: :engine_generator do
        subject { described_class.new(generator, original_class, 1, 2) }
        let(:original_class) { code_specie.original }
        let(:code_specie) { generator.specie_class(:bridge) }
        let(:generator) do
          stub_generator(base_specs: [dept_bridge_base], specific_specs: [])
        end

        it_behaves_like :all_common_empty_specie_checks

        describe '#base_class_name' do
          let(:base_class_name) do
            'ParentsSwapWrapper<Empty<SYMMETRIC_BRIDGE>, OriginalBridge, 1, 2>'
          end
          it { expect(subject.base_class_name).to eq(base_class_name) }
        end
      end

    end
  end
end
