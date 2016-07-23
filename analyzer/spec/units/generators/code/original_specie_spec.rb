require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe OriginalSpecie, type: :code do
        subject { described_class.new(internal_generator, specie_class) }
        let(:internal_generator) { specie_class.send(:generator) }
        let(:specie_class) { code_bridge_base }

        describe '#template_name' do
          it { expect(subject.template_name).to eq('specie') }
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
          it { expect(subject.enum_name).to eq('BRIDGE') }
        end

        describe '#target_specie' do
          it { expect(subject.target_specie).to eq(code_bridge_base) }
        end

        describe '#base_class_names' do
          let(:name) { 'Base<SourceSpec<BaseSpec, 3>, BRIDGE, 3>' }
          it { expect(subject.base_class_names).to eq([name]) }
        end

        describe '#full_file_path' do
          let(:ffp) { 'species/originals/original_bridge.h' }
          it { expect(subject.full_file_path.to_s).to eq(ffp) }
        end
      end

    end
  end
end
