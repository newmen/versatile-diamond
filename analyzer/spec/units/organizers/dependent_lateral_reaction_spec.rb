require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe DependentLateralReaction, type: :organizer do
      subject { dept_middle_lateral_df }

      describe '#sidepiece_specs' do
        it { expect(subject.sidepiece_specs.map(&:name)).to eq([:'dimer()'] * 2) }
      end

      describe '#chunk' do
        it { expect(subject.chunk.same?(middle_chunk)).to be_truthy }
      end

      describe '#theres' do
        it { expect(subject.theres.first).to be_a(DependentThere) }

        describe 'internal caching' do
          it { expect(subject.theres).to eq(subject.theres) }
        end
      end

      describe '#lateral_targets' do
        shared_examples_for :check_targets do
          let(:ab) { dept_reaction.reaction.source.first }
          let(:aib) { dept_reaction.reaction.source.last }
          let(:targets) { [[ab, ab.atom(:ct)], [aib, aib.atom(:ct)]] }
          it { expect(dept_reaction.lateral_targets).to match_array(targets) }
        end

        it_behaves_like :check_targets do
          let(:dept_reaction) { dept_end_lateral_df }
        end

        it_behaves_like :check_targets do
          let(:dept_reaction) { dept_middle_lateral_df }
        end
      end

      describe '#lateral?' do
        it { expect(subject.lateral?).to be_truthy }
      end

      describe 'DependentTypicalReaction#organize_dependencies!' do
        let(:lateral_reactions) do
          [dept_end_lateral_df, dept_middle_lateral_df]
        end

        shared_examples_for :organize_and_check do
          before { typical_reaction.organize_dependencies!(lateral_reactions) }

          describe '#parents' do
            it { expect(lateral_reaction.parents).to eq(parents) }
          end

          describe '#children' do
            it { expect(lateral_reaction.children).to match_array(children) }
          end
        end

        it_behaves_like :organize_and_check do
          let(:typical_reaction) { dept_dimer_formation }
          let(:lateral_reaction) { dept_middle_lateral_df }
          let(:parents) { [dept_end_lateral_df] * 2 }
          let(:children) { [] }
        end

        it_behaves_like :organize_and_check do
          let(:typical_reaction) { dept_dimer_formation }
          let(:lateral_reaction) { dept_end_lateral_df }
          let(:parents) { [typical_reaction] }
          let(:children) { [dept_middle_lateral_df] * 2 }
        end
      end
    end

  end
end
