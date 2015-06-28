require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe TotalChunk, type: :organizer do
      before do
        stub_results(
          typical_reactions: [typical_reaction],
          lateral_reactions: lateral_reactions)
      end

      subject { described_class.new(typical_reaction, chunks) }
      let(:typical_reaction) { dept_dimer_formation }
      let(:chunks) { lateral_reactions.map(&:chunk) }

      let(:targets_num) { 2 }

      shared_examples_for :check_vertexes_and_relations_num do
        it 'expect vertex and relations num in subject links' do
          links = subject.send(method_name)
          expect(links.keys.size).to eq(vertex_num)
          expect(links.values.map(&:size).reduce(:+)).to eq(relations_num)
        end
      end

      shared_examples_for :check_total_and_clean_links do
        it { expect(subject.targets.size).to eq(targets_num) }

        it_behaves_like :check_vertexes_and_relations_num do
          let(:method_name) { :total_links }
          let(:vertex_num) { total_vertex_num }
          let(:relations_num) { total_relations_num }
        end

        it_behaves_like :check_vertexes_and_relations_num do
          let(:method_name) { :clean_links }
          let(:vertex_num) { clean_vertex_num }
          let(:relations_num) { clean_relations_num }
        end
      end

      it_behaves_like :check_total_and_clean_links do
        let(:lateral_reactions) { [dept_end_lateral_df] }
        let(:total_vertex_num) { 12 }
        let(:total_relations_num) { 32 }
        let(:clean_vertex_num) { 4 }
        let(:clean_relations_num) { 4 }

        describe '#-' do
          let(:chunk) { lateral_reactions.first.chunk }
          let(:subtract) { subject - chunk }
          it { expect(subtract.fully_matched?).to be_truthy }
        end
      end

      it_behaves_like :check_total_and_clean_links do
        let(:lateral_reactions) { [dept_end_lateral_df, dept_middle_lateral_df] }
        let(:total_vertex_num) { 18 }
        let(:total_relations_num) { 50 }
        let(:clean_vertex_num) { 6 }
        let(:clean_relations_num) { 8 }

        describe '#-' do
          let(:chunk) { lateral_reactions.first.chunk }
          let(:subtract) { subject - chunk - chunk }
          it { expect(subtract.fully_matched?).to be_truthy }
        end
      end

      it_behaves_like :check_total_and_clean_links do
        let(:lateral_reactions) { [dept_ewb_lateral_df] }
        let(:total_vertex_num) { 15 }
        let(:total_relations_num) { 40 }
        let(:clean_vertex_num) { 5 }
        let(:clean_relations_num) { 6 }
      end

      it_behaves_like :check_total_and_clean_links do
        let(:lateral_reactions) { [dept_ewb_lateral_df, dept_middle_lateral_df] }
        let(:total_vertex_num) { 21 }
        let(:total_relations_num) { 58 }
        let(:clean_vertex_num) { 7 }
        let(:clean_relations_num) { 10 }
      end
    end
  end
end
