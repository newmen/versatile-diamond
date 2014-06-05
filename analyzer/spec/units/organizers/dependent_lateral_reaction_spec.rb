require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe DependentLateralReaction do
      def wrap(reaction)
        described_class.new(reaction)
      end

      subject { wrap(middle_lateral_df) }

      describe '#wheres' do
        it { expect(subject.wheres).to match_array([at_middle]) }
      end

      describe '#theres' do
        it { expect(subject.theres.map(&:class)).to eq([DependentThere]) }
      end

      describe '#lateral?' do
        it { expect(subject.lateral?).to be_truthy }
      end

      describe '#organize_dependencies!' do
        let(:target) { wrap(end_lateral_df) }
        let(:other) do
          wrap(dimer_formation.lateral_duplicate('other', [on_end, there_methyl]))
        end

        let(:lateral_reactions) { [target, subject, other] }

        before do
          lateral_reactions.each do |reaction|
            reaction.organize_dependencies!(lateral_reactions)
          end
        end

        describe '#parent' do
          it { expect(subject.parent).to eq(target) }
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
