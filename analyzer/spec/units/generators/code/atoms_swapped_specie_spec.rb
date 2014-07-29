require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe AtomsSwappedSpecie, type: :code do
        subject { described_class.new(empty_generator, original_class, 1, 2) }
        let(:original_class) { OriginalSpecie.new(empty_generator, code_bridge_base) }

        it_behaves_like :all_common_empty_specie_checks

        describe '#base_class_name' do
          let(:base_class_name) { 'AtomsSwapWrapper<Empty<SYMMETRIC_BRIDGE>, 1, 2>' }
          it { expect(subject.base_class_name).to eq(base_class_name) }
        end

        describe 'wrap another empty specie' do
          subject { described_class.new(empty_generator, empty_class, 1, 2) }
          let(:original_class) { OriginalSpecie.new(empty_generator, code_dimer_base) }
          let(:empty_class) do
            args = [empty_generator, original_class, 0, 1]
            ParentsSwappedSpecie.new(*args, registrate: false)
          end
          let(:cap_name) { 'Dimer' }
  
          it_behaves_like :empty_specie_name_methods
          it_behaves_like :twise_specie_name_methods do
            let(:another) { described_class.new(empty_generator, empty_class, 4, 5) }
          end
        end
      end

    end
  end
end
