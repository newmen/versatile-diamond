module VersatileDiamond
  module Organizers
    module Support

      module MinuendExamples
        shared_examples_for :minuend do
          describe '#same?' do
            it { expect(subject.same?(subject)).to be_true }
          end

          describe '#links_size' do
            it { expect(subject.links_size).to eq(subject.links.size) }
          end
        end

        shared_examples_for :swap_to_atom_reference do
          let(:keys) { subject.links.keys }

          it { expect(subject.links_size - subject.refs_num).to eq(atoms_num) }
          it { expect(subject.refs_num).to eq(refs_num) }
        end

      end

    end
  end
end
