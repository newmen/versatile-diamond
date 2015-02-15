require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe DependentTypicalReaction, type: :organizer do
      describe '#source_covered_by' do
        describe 'methyl activation' do
          subject { dept_methyl_activation }
          let(:spec) { subject.each_source.to_a.first }

          it { expect(subject.source_covered_by(active_bond)).to be_nil }
          it { expect(subject.source_covered_by(adsorbed_h)).to eq(spec) }
        end

        describe 'methyl deactivation' do
          subject { dept_methyl_deactivation }
          let(:spec) { subject.each_source.to_a.first }

          it { expect(subject.source_covered_by(active_bond)).to eq(spec) }
          it { expect(subject.source_covered_by(adsorbed_h)).to eq(spec) }
        end
      end

      describe '#lateral?' do
        it { expect(dept_dimer_formation.lateral?).to be_falsey }
      end

      describe '#organize_dependencies!' do
        let(:lateral_reactions) do
          [dept_end_lateral_df, dept_middle_lateral_df]
        end

        shared_examples_for :organize_and_check do
          before { reaction.organize_dependencies!(lateral_reactions) }

          describe '#parents' do
            it 'each complex have a parents' do
              complexes.each do |complex|
                expect(complex.parents).to eq([reaction])
              end
            end
          end

          describe '#complexes' do
            it { expect(reaction.complexes).to match_array(complexes) }
          end
        end

        it_behaves_like :organize_and_check do
          let(:reaction) { dept_dimer_formation }
          let(:complexes) { lateral_reactions }
        end

        it_behaves_like :organize_and_check do
          let(:reaction) { dept_methyl_desorption }
          let(:complexes) { [] }
        end
      end
    end

  end
end
