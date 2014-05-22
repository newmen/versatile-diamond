module VersatileDiamond
  module Organizers
    module Support

      module MinuendExamples
        shared_examples_for :minuend do
          describe '#same?' do
            it { expect(subject.same?(subject)).to be_true }
          end

          describe '#empty?' do
            it { expect(subject.empty?).to be_false }
          end

          describe '#atoms_num' do
            it { expect(subject.atoms_num).to eq(subject.links.size) }
          end
        end

        shared_examples_for :swap_to_atom_reference do
          let(:keys) { subject.links.keys }

          it { expect(subject.atoms_num - subject.relations_num).to eq(atoms_num) }
          it { expect(subject.relations_num).to eq(relations_num) }
        end

      end

    end
  end
end
