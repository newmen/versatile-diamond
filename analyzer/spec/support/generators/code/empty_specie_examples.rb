module VersatileDiamond
  module Organizers
    module Code
      module Support

        module EmptySpecieExamples
          shared_examples_for :empty_specie_template_methods do
            describe '#template_name' do
              it { expect(subject.template_name).to eq('empty_specie') }
            end

            describe '#original_class_name' do
              it { expect(subject.original_class_name).to eq("Original#{cap_name}") }
            end

            describe '#original_file_path' do
              let(:value) { "species/originals/original_#{cap_name.downcase}.h" }
              it { expect(subject.original_file_path.to_s).to eq(value) }
            end

            describe '#outer_base_name' do
              it { expect(subject.outer_base_name).to eq('empty_base') }
            end
          end

          shared_examples_for :empty_specie_name_methods do
            describe 'without suffix' do
              describe '#define_name' do
                let(:value) { "SYMMETRIC_#{cap_name.upcase}_H" }
                it { expect(subject.define_name).to eq(value) }
              end

              let(:file_name) { "symmetric_#{cap_name.downcase}" }
              describe '#file_name' do
                it { expect(subject.file_name).to eq(file_name) }
              end

              describe '#full_file_path' do
                let(:ffp) { "species/empties/#{file_name}.h" }
                it { expect(subject.full_file_path.to_s).to eq(ffp) }
              end

              describe '#class_name' do
                it { expect(subject.class_name).to eq("Symmetric#{cap_name}") }
              end

              describe '#enum_name' do
                it { expect(subject.enum_name).to eq(cap_name.upcase) }
              end

              describe '#print_name' do
                it { expect(subject.print_name).to eq("symmetric_#{cap_name.downcase}") }
              end
            end

            describe 'with suffix' do
              before { subject.set_suffix(1) }

              describe '#define_name' do
                let(:define_name) { "SYMMETRIC_#{cap_name.upcase}1_H" }
                it { expect(subject.define_name).to eq(define_name) }
              end

              let(:file_name) { "symmetric_#{cap_name.downcase}1" }
              describe '#file_name' do
                it { expect(subject.file_name).to eq(file_name) }
              end

              describe '#full_file_path' do
                let(:ffp) { "species/empties/#{file_name}.h" }
                it { expect(subject.full_file_path.to_s).to eq(ffp) }
              end

              describe '#class_name' do
                it { expect(subject.class_name).to eq("Symmetric#{cap_name}1") }
              end

              describe '#enum_name' do
                # without suffix any time
                it { expect(subject.enum_name).to eq(cap_name.upcase) }
              end

              describe '#print_name' do
                # without suffix any time
                it { expect(subject.print_name).to eq("symmetric_#{cap_name.downcase}") }
              end
            end
          end

          shared_examples_for :all_common_empty_specie_checks do
            let(:cap_name) { 'Bridge' }

            it_behaves_like :empty_specie_template_methods
            it_behaves_like :empty_specie_name_methods
          end
        end

      end
    end
  end
end
