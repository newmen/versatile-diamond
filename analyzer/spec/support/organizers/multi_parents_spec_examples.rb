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
        end
      end

    end
  end
end
