require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe ChunkLinksMerger, type: :organizer do
      describe 'described_class#global_cache' do
        before { described_class.init_veiled_cache! }
        it { expect(described_class.global_cache).to eq({}) }
      end

      describe '#merge' do
        subject { described_class.new }
        let(:typical_reaction) { dept_dimer_formation }
        let(:chunk) { end_chunk }

        shared_examples_for :check_merge do
          before { chunk.lateral_reaction.send(:store_parent, typical_reaction) }

          let(:chunks) { [chunk] * env_specs_num }
          let(:mirror) { chunk.mapped_targets.invert }
          let(:result) { chunks.reduce({}, &subject.public_method(:merge)) }
          let(:result_with_correct_specs) do
            result.each_with_object({}) do |(spec_atom, rels), acc|
              acc[mirror[spec_atom] || spec_atom] = rels.map do |sa, r|
                [mirror[sa] || sa, r]
              end
            end
          end

          let(:or_specs) { result.keys().map(&:first).to_set }
          let(:fr_specs) { result_with_correct_specs.keys().map(&:first).to_set }
          let(:env_specs) { (or_specs & fr_specs).to_a }

          it { expect(env_specs.size).to eq(env_specs_num) }
        end

        it_behaves_like :check_merge do
          let(:env_specs_num) { 1 }
          it { expect(result_with_correct_specs).to match_graph(end_chunk.links) }
        end

        it_behaves_like :check_merge do
          let(:env_specs_num) { 2 }
        end

        it_behaves_like :check_merge do
          let(:env_specs_num) { 3 }
        end

        it_behaves_like :check_merge do
          before do
            middle_chunk.lateral_reaction.send(:store_parent, typical_reaction)
          end

          let(:chunks) { [end_chunk, middle_chunk] }
          let(:env_specs_num) { 3 }
        end
      end
    end

  end
end
