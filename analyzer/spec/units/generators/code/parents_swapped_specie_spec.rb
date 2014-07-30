require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe ParentsSwappedSpecie, type: :code do
        subject { described_class.new(empty_generator, original_class, 1, 2) }
        let(:original_class) { OriginalSpecie.new(empty_generator, code_bridge_base) }

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
