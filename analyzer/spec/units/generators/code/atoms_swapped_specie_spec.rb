require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe AtomsSwappedSpecie, type: :code do
        subject { described_class.new(empty_class, 1, 2) }
        let(:original_class) { OriginalSpecie.new(empty_generator, code_bridge_base) }
        let(:empty_class) { EmptySpecie.new(empty_generator, original_class) }

        it_behaves_like :empty_bridge_template_methods

        describe '#base_class_name' do
          let(:base_class_name) { 'AtomsSwapWrapper<Empty<SYMMETRIC_BRIDGE>, 1, 2>' }
          it { expect(subject.base_class_name).to eq(base_class_name) }
        end

        describe 'without index' do
          it_behaves_like :empty_bridge_name_methods
        end

        describe 'with index' do
          # creates another symmetric instance for get an index
          before { described_class.new(empty_class, 0, 1) } # <- fake indexes

          describe '#define_name' do
            it { expect(subject.define_name).to eq('SYMMETRIC_BRIDGE1_H') }
          end

          describe '#file_name' do
            it { expect(subject.file_name).to eq('symmetric_bridge1') }
          end

          describe '#class_name' do
            it { expect(subject.class_name).to eq('SymmetricBridge1') }
          end

          describe '#enum_name anytime without index' do
            it { expect(subject.enum_name).to eq('SYMMETRIC_BRIDGE') }
          end
        end
      end

    end
  end
end
