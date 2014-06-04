module VersatileDiamond
  module Organizers
    module Support

      module MinuendExamples
        shared_examples_for :minuend do
          describe '#same?' do
            it { expect(subject.same?(subject)).to be_truthy }
          end

          describe '#empty?' do
            it { expect(subject.empty?).to be_falsey }
          end

          describe '#atoms_num' do
            it { expect(subject.atoms_num).to eq(subject.links.size) }
          end
        end

        shared_examples_for :count_atoms_and_references do
          it { expect(subject.atoms_num).to eq(atoms_num) }
          it { expect(subject.relations_num).to eq(relations_num) }
        end

      end

    end
  end
end
