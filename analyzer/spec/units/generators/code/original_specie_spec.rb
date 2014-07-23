require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe OriginalSpecie, type: :code do
        subject { described_class.new(empty_generator, specie_class) }
        let(:specie_class) { code_bridge_base }

        describe '#main_specie' do
          it { expect(subject.main_specie).to eq(code_bridge_base) }
        end

        describe '#template_name' do
          it { expect(subject.template_name).to eq(specie_class.template_name) }
        end

        describe '#define_name' do
          it { expect(subject.define_name).to eq('ORIGINAL_BRIDGE_H') }
        end

        describe '#file_name' do
          it { expect(subject.file_name).to eq('original_bridge') }

          describe 'more complex name' do
            let(:specie_class) { code_activated_methyl_on_incoherent_bridge }
            it { expect(subject.file_name).to eq('original_methyl_on_bridge_cbi_cms') }
          end
        end

        describe '#class_name' do
          it { expect(subject.class_name).to eq('OriginalBridge') }
        end

        describe '#enum_name' do
          it { expect(subject.enum_name).to eq('ORIGINAL_BRIDGE') }
        end

        describe '#base_classes' do
          let(:name) { 'Base<SourceSpec<BaseSpec, 3>, BRIDGE, 3>' }
          it { expect(subject.base_classes).to eq([name]) }
        end
      end

    end
  end
end
