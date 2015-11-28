require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe ChunkLinksMerger, type: :organizer do
      describe 'described_class#global_cache' do
        before { described_class.init_veiled_cache! }
        it { expect(described_class.global_cache).to eq({}) }
      end

      describe '#merge' do
        before do
          stub_results({
            typical_reactions: [typical_reaction],
            lateral_reactions: lateral_reactions
          })
        end

        subject { described_class.new(chunk.target_specs.to_set) }
        let(:typical_reaction) { dept_dimer_formation }
        let(:lateral_reactions) { [dept_end_lateral_df] }

        shared_examples_for :check_merge do
          let(:chunk) { lateral_reactions.first.chunk }
          let(:chunks) { [chunk] * env_specs_num }
          let(:mirror) { chunk.mapped_targets.invert }
          let(:result) { chunks.reduce({}, &subject.public_method(:merge)) }
          let(:env_specs) { result.keys.map(&:first).to_set - chunk.target_specs }

          it { expect(env_specs.size).to eq(env_specs_num) }
        end

        it_behaves_like :check_merge do
          let(:env_specs_num) { 1 }
        end

        it_behaves_like :check_merge do
          let(:env_specs_num) { 2 }
        end

        it_behaves_like :check_merge do
          let(:env_specs_num) { 3 }
        end

        it_behaves_like :check_merge do
          let(:lateral_reactions) { [dept_end_lateral_df, dept_middle_lateral_df] }
          let(:chunks) { [end_chunk, middle_chunk] }
          let(:env_specs_num) { 3 }
        end
      end
    end

  end
end
