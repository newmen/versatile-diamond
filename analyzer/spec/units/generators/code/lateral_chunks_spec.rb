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
        let(:sidepiece_specs) { subject.sidepiece_specs.to_a }
        let(:lateral_bridge) do
          sidepiece_specs.select { |spec| spec.name == :bridge }.first
        end
        let(:lateral_dimer) do
          sidepiece_specs.select { |spec| spec.name == :dimer }.first
        end

        describe '#total_chunk' do
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

        describe '#side_keys' do
          let(:lateral_reactions) { [dept_ewb_lateral_df] }
          it 'check spec-atom pairs' do
            specs_atoms = subject.side_keys
            expect(specs_atoms.size).to eq(3)

            uniq_sidepiece_specs = specs_atoms.map(&:first).uniq
            expect(uniq_sidepiece_specs).to match_array(subject.sidepiece_specs)

            atoms = specs_atoms.map(&:last)
            expect(atoms.uniq).to match_array(atoms)

            expect(specs_atoms.select { |s, _| s == lateral_bridge }.size).to eq(1)
            expect(specs_atoms.select { |s, _| s == lateral_dimer }.size).to eq(2)
          end
        end

        describe '#select_reaction' do
          let(:lateral_reactions) { [dept_ewb_lateral_df] }
          let(:spec_atom) { [lateral_bridge, lateral_bridge.atom(:ct)] }
          let(:chunk) { subject.select_reaction(spec_atom).chunk }
          it { expect(chunk.original?).to be_falsey }
          it { expect(chunk.sidepiece_specs.size).to eq(1) }
        end

        describe '#unconcrete_affixes_without' do
          let(:lateral_reactions) { [dept_end_lateral_df, dept_ewb_lateral_df] }
          let(:specie) { generator.specie_class(lateral_bridge.name) }
          let(:affixes) do
            subject.unconcrete_affixes_without(dept_end_lateral_df, specie)
          end

          it 'check affixes' do
            expect(affixes.size).to eq(1)
            expect(affixes.map(&:chunk).any?(&:original?)).to be_truthy
          end
        end
      end

    end
  end
end
