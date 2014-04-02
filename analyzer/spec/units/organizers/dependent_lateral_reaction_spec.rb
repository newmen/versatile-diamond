require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe DependentLateralReaction do
      def wrap(reaction)
        described_class.new(reaction)
      end

      describe '#theres' do
        subject { wrap(middle_lateral_df) }
        it { expect(subject.theres.map(&:class)).to eq([DependentThere]) }
      end

      describe '#organize_dependencies!' do
        let(:target) { wrap(end_lateral_df) }
        let(:middle) { wrap(middle_lateral_df) }
        let(:other) do
          wrap(dimer_formation.lateral_duplicate('other', [on_end, there_methyl]))
        end

        let(:lateral_reactions) { [target, middle, other] }

        before do
          lateral_reactions.each do |reaction|
            reaction.organize_dependencies!(lateral_reactions)
          end
        end

        describe '#complexes' do
          it { expect(target.complexes).to match_array([middle, other]) }
          it { expect(middle.complexes).to be_empty }
          it { expect(other.complexes).to be_empty }
        end
      end
    end

  end
end
