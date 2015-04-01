require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe ChunksTable, type: :organizer do
      subject { described_class.new(all_chunks) }
      let(:all_chunks) { [end_chunk, middle_chunk, ewb_chunk].shuffle }

      describe '#best' do
        shared_examples_for :check_parents do
          let(:best) { subject.best(chunk) }
          it { expect(best).to be_a(ChunkResidual) }
          it { expect(best.parents).to eq(parents) }
        end

        it_behaves_like :check_parents do
          let(:chunk) { end_chunk }
          let(:parents) { [] }
        end

        it_behaves_like :check_parents do
          let(:chunk) { middle_chunk }
          let(:parents) { [end_chunk] * 2 }
        end

        it_behaves_like :check_parents do
          let(:chunk) { ewb_chunk }
          let(:parents) { [end_chunk] }
        end
      end
    end

  end
end
