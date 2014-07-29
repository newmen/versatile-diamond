require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe ParentsSwappedSpecie, type: :code do
        subject { described_class.new(empty_generator, original_class, 1, 2) }
        let(:original_class) { OriginalSpecie.new(empty_generator, code_bridge_base) }

        it_behaves_like :empty_bridge_template_methods
        it_behaves_like :empty_bridge_name_methods
        it_behaves_like :twise_bridge_name_methods do
          before do
            # creates another symmetric instance for get an index in names
            described_class.new(empty_generator, original_class, 0, 1) # fake indexes
          end
        end

        describe '#base_class_name' do
          let(:base_class_name) { 'ParentsSwapWrapper<Empty<SYMMETRIC_BRIDGE>, 1, 2>' }
          it { expect(subject.base_class_name).to eq(base_class_name) }
        end
      end

    end
  end
end
