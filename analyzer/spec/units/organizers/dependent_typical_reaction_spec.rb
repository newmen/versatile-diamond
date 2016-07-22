require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe DependentTypicalReaction, type: :organizer do
      describe '#source_covered_by' do
        describe 'methyl activation' do
          subject { dept_methyl_activation }
          let(:spec) { subject.each(:source).to_a.first }

          it { expect(subject.source_covered_by(active_bond)).to be_nil }
          it { expect(subject.source_covered_by(adsorbed_h)).to eq(spec) }
        end

        describe 'methyl deactivation' do
          subject { dept_methyl_deactivation }
          let(:spec) { subject.each(:source).to_a.first }

          it { expect(subject.source_covered_by(active_bond)).to eq(spec) }
          it { expect(subject.source_covered_by(adsorbed_h)).to eq(spec) }
        end
      end

      describe '#lateral?' do
        it { expect(dept_dimer_formation.lateral?).to be_falsey }
      end

      describe '#organize_dependencies!' do
        before do
          stub_results({
            typical_reactions: [typical_reaction],
            lateral_reactions: lateral_reactions
          })
        end

        shared_examples_for :organize_and_check do
          let(:lateral_reactions) { [dept_end_lateral_df, dept_middle_lateral_df] }

          describe '#parents' do
            it 'each complex have a parents' do
              children.each do |complex|
                expect(complex.parent).to eq(typical_reaction)
              end
            end
          end

          describe '#children' do
            it { expect(typical_reaction.children).to match_array(children) }
          end
        end

        it_behaves_like :organize_and_check do
          let(:typical_reaction) { dept_dimer_formation }
          let(:children) { lateral_reactions }
        end

        it_behaves_like :organize_and_check do
          let(:typical_reaction) { dept_methyl_desorption }
          let(:children) { [] }
        end
      end

      describe '#combine_children_laterals!' do
        let(:typical_reaction) { dept_dimer_formation }
        let(:lateral_reactions) { [dept_end_lateral_df, dept_ewb_lateral_df] }
        let(:cmb_reactions) { typical_reaction.children - lateral_reactions }

        before do
          Tools::Config.surface_temperature(0, 'C')
          dimer_formation.activation = 0
          dimer_formation.rate = 1
          end_lateral_df.activation = 0
          end_lateral_df.rate = 22
          ewb_lateral_df.activation = 0
          ewb_lateral_df.rate = 3

          stub_results({
            typical_reactions: [typical_reaction],
            lateral_reactions: lateral_reactions
          })
        end

        it 'array of new lateral reactions' do
          expect(end_chunk.parents).to be_empty
          expect(ewb_chunk.parents).to include(end_chunk)
          expect(ewb_chunk.parents).not_to eq([end_chunk] * 2)
          expect(ewb_chunk.parents.size).to eq(2)

          expect(cmb_reactions.size).to eq(3)
          expect(cmb_reactions.map(&:full_rate)).to match_array([1.0, 22.0, 3.0])
        end
      end
    end

  end
end
