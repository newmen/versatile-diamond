module VersatileDiamond
  module Organizers
    module Support

      module MinuendSpecExamples
        shared_examples_for :check_clean_links do
          describe '#clean_links' do
            it { expect(subject.clean_links).to match_graph(clean_links) }
          end
        end

        shared_examples_for :minuend do
          describe '#<' do
            it { expect(subject < subject).to be_falsey }
            it { expect(subject < bigger).to be_truthy }
            it { expect(bigger < subject).to be_falsey }
          end

          describe '#<=' do
            it { expect(subject <= subject).to be_truthy }
            it { expect(subject <= bigger).to be_truthy }
            it { expect(bigger <= subject).to be_falsey }
          end

          describe '#relations_of' do
            it { expect(subject.relations_of(atom)).to match_array(atom_relations) }
          end

          it_behaves_like :check_clean_links
        end

        shared_examples_for :count_atoms_and_relations_and_parents do
          let(:slinks) { subject.links }
          it { expect(slinks.size).to eq(atoms_num) }
          it { expect(slinks.values.map(&:size).reduce(:+)).to eq(relations_num) }
          it { expect(subject.parents.size).to eq(parents_num) }
        end
      end

    end
  end
end
