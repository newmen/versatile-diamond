module VersatileDiamond
  module Organizers
    module Support

      module MultiChildrenSpecExamples
        shared_examples_for :multi_children do
          describe '#children' do
            it { expect(parent.children).to be_empty }
          end

          describe '#store_children' do
            before { parent.store_child(child) }
            it { expect(parent.children).to eq([child]) }
          end

          describe '#remove_child' do
            before do
              child.store_parent(parent)
              parent.remove_child(child)
            end

            it { expect(parent.children).to be_empty }
            it { expect(child.parents).to eq([parent]) }
          end
        end
      end

    end
  end
end
