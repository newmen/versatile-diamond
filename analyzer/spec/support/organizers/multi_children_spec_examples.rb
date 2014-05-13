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
        end
      end

    end
  end
end
