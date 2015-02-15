require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe DependentLateralReaction, type: :organizer do
      subject { dept_middle_lateral_df }

      describe '#sidepiece_specs' do
        it { expect(subject.sidepiece_specs.map(&:name)).to eq([:'dimer()'] * 2) }
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

      describe '#cover?' do
        let(:other) { described_class.new(concept) }
        let(:concept) do
          dimer_formation.lateral_duplicate('other', [on_end, there_methyl])
        end

        it { expect(subject.cover?(dept_end_lateral_df)).to be_truthy }
        it { expect(other.cover?(dept_end_lateral_df)).to be_truthy }

        it { expect(dept_end_lateral_df.cover?(subject)).to be_falsey }
        it { expect(dept_end_lateral_df.cover?(other)).to be_falsey }
      end

      describe '#lateral?' do
        it { expect(subject.lateral?).to be_truthy }
      end

      describe '#organize_dependencies!' do
        let(:target) { dept_end_lateral_df }
        let(:other) { described_class.new(other_concept) }
        let(:other_concept) do
          dimer_formation.lateral_duplicate('other', [on_end, there_methyl])
        end

        let(:lateral_reactions) { [target, subject, other] }

        before do
          lateral_reactions.each do |reaction|
            reaction.organize_dependencies!(lateral_reactions)
          end
        end

        describe '#parents' do
          it { expect(subject.parents).to eq([target]) }
        end

        describe '#complexes' do
          it { expect(target.complexes).to match_array([subject, other]) }
          it { expect(subject.complexes).to be_empty }
          it { expect(other.complexes).to be_empty }
        end
      end
    end

  end
end
