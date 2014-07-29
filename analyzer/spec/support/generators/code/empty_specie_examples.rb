module VersatileDiamond
  module Organizers
    module Support

      module EmptySpecieExamples
        shared_examples_for :empty_specie_template_methods do
          describe '#counter_key' do
            it { expect(subject.counter_key).to eq(:bridge) }
          end

          describe '#template_name' do
            it { expect(subject.template_name).to eq('empty_specie') }
          end

          describe '#original_class_name' do
            it { expect(subject.original_class_name).to eq("Original#{cap_name}") }
          end

          describe '#original_file_path' do
            let(:value) { "base/original_#{cap_name.downcase}" }
            it { expect(subject.original_file_path).to eq(value) }
          end

          describe '#outer_base_file' do
            it { expect(subject.outer_base_file).to eq('empty') }
          end
        end

        shared_examples_for :empty_specie_name_methods do
          describe '#define_name' do
            it { expect(subject.define_name).to eq("SYMMETRIC_#{cap_name.upcase}_H") }
          end

          describe '#file_name' do
            it { expect(subject.file_name).to eq("symmetric_#{cap_name.downcase}") }
          end

          describe '#class_name' do
            it { expect(subject.class_name).to eq("Symmetric#{cap_name}") }
          end

          describe '#enum_name' do
            it { expect(subject.enum_name).to eq("SYMMETRIC_#{cap_name.upcase}") }
          end
        end

        shared_examples_for :twise_specie_name_methods do
          before do
            subject # creates subject
            another # creates another symmetric instance for get an index in names
          end

          describe '#define_name' do
            it { expect(subject.define_name).to eq("SYMMETRIC_#{cap_name.upcase}1_H") }
          end

          describe '#file_name' do
            it { expect(subject.file_name).to eq("symmetric_#{cap_name.downcase}1") }
          end

          describe '#class_name' do
            it { expect(subject.class_name).to eq("Symmetric#{cap_name}1") }
          end

          describe '#enum_name' do
            # without index any time
            it { expect(subject.enum_name).to eq("SYMMETRIC_#{cap_name.upcase}") }
          end
        end

        shared_examples_for :all_common_empty_specie_checks do
          let(:cap_name) { 'Bridge' }

          it_behaves_like :empty_specie_template_methods
          it_behaves_like :empty_specie_name_methods
          it_behaves_like :twise_specie_name_methods do
            let(:another) do
              described_class.new(empty_generator, original_class, 0, 1) # fake indexes
            end
          end
        end
      end

    end
  end
end
