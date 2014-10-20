module VersatileDiamond
  module Organizers
    module Support

      module DependentWrappedSpecExamples
        shared_examples_for :wrapped_spec do
          describe '#target' do
            it { expect(subject.target).to eq(subject) }
          end

          describe '#parents' do
            it { expect(subject.parents).to be_empty }
          end

          describe '#children' do
            it { expect(subject.children).to be_empty }
          end

          describe '#store_child' do
            before { subject.store_child(child) }
            it { expect(subject.children).to eq([child]) }
          end

          describe '#non_term_children' do
            before do
              subject.store_child(dept_active_bond)
              subject.store_child(dept_adsorbed_h)
            end
            it { expect(subject.non_term_children).to eq([]) }

            describe 'wish non term children' do
              before { subject.store_child(child) }
              it { expect(subject.non_term_children).to eq([child]) }
            end
          end
        end

        shared_examples_for :organize_dependencies do
          before do
            all = [subject] + others
            bases = all.reject(&:specific?)
            specifics = all - bases

            organize_base_specs_dependencies!(bases) unless bases.empty?

            unless specifics.empty?
              organize_specific_specs_dependencies!(make_cache(bases), specifics)
            end
          end
        end
      end

    end
  end
end
