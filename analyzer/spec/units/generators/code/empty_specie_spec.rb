require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe EmptySpecie, type: :code do
        subject { described_class.new(empty_generator, original_class) }
        let(:original_class) { OriginalSpecie.new(empty_generator, code_bridge_base) }

        it_behaves_like :empty_bridge_template_methods
        it_behaves_like :empty_bridge_name_methods

        describe '#base_class_name' do
          it { expect(subject.base_class_name).to eq('Empty<SYMMETRIC_BRIDGE>') }
        end
      end

    end
  end
end
