require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe LateralChunks, type: :code do
        let(:generator) do
          stub_generator(
            typical_reactions: [target_reaction],
            lateral_reactions: lateral_reactions)
        end

        subject { typical_reaction.lateral_chunks }
        let(:target_reaction) { dept_dimer_formation }
        let(:typical_reaction) { generator.reaction_class(target_reaction.name) }

        shared_examples_for :check_vertexes_and_relations_num do
          it 'expect vertex and relations num in subject links' do
            links = subject.send(method_name)
            expect(links.keys.size).to eq(vertex_num)
            expect(links.values.map(&:size).reduce(:+)).to eq(relations_num)
          end
        end

        shared_examples_for :check_root_total_and_clean do
          it { expect(subject.root_times).to eq(root_times) }

          it_behaves_like :check_vertexes_and_relations_num do
            let(:method_name) { :links }
            let(:vertex_num) { total_vertex_num }
            let(:relations_num) { total_relations_num }
          end

          it_behaves_like :check_vertexes_and_relations_num do
            let(:method_name) { :clean_links }
            let(:vertex_num) { clean_vertex_num }
            let(:relations_num) { clean_relations_num }
          end
        end

        describe 'just two sides' do
          let(:root_times) { 2 }
          let(:total_vertex_num) { 12 }
          let(:total_relations_num) { 32 }
          let(:clean_vertex_num) { 4 }
          let(:clean_relations_num) { 4 }

          it_behaves_like :check_root_total_and_clean do
            let(:lateral_reactions) { [dept_end_lateral_df] }
          end

          it_behaves_like :check_root_total_and_clean do
            let(:lateral_reactions) { [dept_end_lateral_df, dept_middle_lateral_df] }
          end
        end

        describe 'complex case' do
          let(:root_times) { 3 }
          let(:total_vertex_num) { 15 }
          let(:total_relations_num) { 40 }
          let(:clean_vertex_num) { 5 }
          let(:clean_relations_num) { 6 }

          it_behaves_like :check_root_total_and_clean do
            let(:lateral_reactions) { [dept_ewb_lateral_df] }
          end

          it_behaves_like :check_root_total_and_clean do
            let(:lateral_reactions) { [dept_ewb_lateral_df, dept_middle_lateral_df] }
          end
        end
      end

    end
  end
end
