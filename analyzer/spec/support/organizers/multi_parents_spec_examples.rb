module VersatileDiamond
  module Organizers
    module Support

      module MultiParentsSpecExamples
        shared_examples_for :multi_parents do
          describe '#store_parent' do
            before { child.store_parent(parent) }

            it { expect(parent.children).to eq([child]) }
            it { expect(child.parents).to eq([parent]) }
          end

          describe '#remove_parent' do
            before do
              child.store_parent(parent)
              child.remove_parent(parent)
            end

            it { expect(parent.children).to eq([child]) }
            it { expect(child.parents).to be_empty }
          end
        end
      end

    end
  end
end
