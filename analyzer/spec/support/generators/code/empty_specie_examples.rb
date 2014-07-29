module VersatileDiamond
  module Organizers
    module Support

      module EmptySpecieExamples
        shared_examples_for :empty_bridge_template_methods do
          describe '#counter_key' do
            it { expect(subject.counter_key).to eq(:bridge) }
          end

          describe '#template_name' do
            it { expect(subject.template_name).to eq('empty_specie') }
          end

          describe '#original_class_name' do
            it { expect(subject.original_class_name).to eq('OriginalBridge') }
          end

          describe '#original_file_path' do
            it { expect(subject.original_file_path).to eq('base/original_bridge') }
          end

          describe '#outer_base_file' do
            it { expect(subject.outer_base_file).to eq('empty') }
          end
        end

        shared_examples_for :empty_bridge_name_methods do
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

        shared_examples_for :twise_bridge_name_methods do
          before do
            subject # creates subject
          end

          describe '#define_name' do
            it { expect(subject.define_name).to eq('SYMMETRIC_BRIDGE1_H') }
          end

          describe '#file_name' do
            it { expect(subject.file_name).to eq('symmetric_bridge1') }
          end

          describe '#class_name' do
            it { expect(subject.class_name).to eq('SymmetricBridge1') }
          end

          describe '#enum_name' do
            # without index any time
            it { expect(subject.enum_name).to eq('SYMMETRIC_BRIDGE') }
          end
        end
      end

    end
  end
end
