require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe EmptySpecie, type: :code do
        subject { described_class.new(empty_generator, original_class) }
        let(:original_class) { OriginalSpecie.new(empty_generator, code_bridge_base) }

        describe '#template_name' do
          it { expect(subject.template_name).to eq('symmetric_specie') }
        end

        describe '#define_name' do
          it { expect(subject.define_name).to eq('SYMMETRIC_BRIDGE_H') }
        end

        describe '#file_name' do
          it { expect(subject.file_name).to eq('symmetric_bridge') }
        end

        describe '#class_name' do
          it { expect(subject.class_name).to eq('SymmetricBridge') }
        end

        describe '#enum_name' do
          it { expect(subject.enum_name).to eq('SYMMETRIC_BRIDGE') }
        end
      end

    end
  end
end
