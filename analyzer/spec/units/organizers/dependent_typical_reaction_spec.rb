require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe DependentTypicalReaction do
      def wrap(reaction)
        described_class.new(reaction)
      end

      describe '#source_covered_by?' do
        it { expect(wrap(methyl_activation).source_covered_by?(adsorbed_h)).
          to be_true }
        it { expect(wrap(methyl_activation).source_covered_by?(active_bond)).
          to be_false }

        it { expect(wrap(methyl_deactivation).source_covered_by?(active_bond)).
          to be_true }
        it { expect(wrap(methyl_deactivation).source_covered_by?(adsorbed_h)).
          to be_true }
      end

      describe '#organize_dependencies!' do
        def lateral(reaction)
          DependentLateralReaction.new(end_lateral_df)
        end

        let(:lateral_reactions) do
          [lateral(end_lateral_df), lateral(middle_lateral_df)]
        end

        shared_examples_for :organize_and_check do
          before { reaction.organize_dependencies!(lateral_reactions) }

          describe '#complexes' do
            it { expect(reaction.complexes).to match_array(complexes) }
          end
        end

        it_behaves_like :organize_and_check do
          let(:reaction) { wrap(dimer_formation) }
          let(:complexes) { lateral_reactions }
        end

        it_behaves_like :organize_and_check do
          let(:reaction) { wrap(methyl_desorption) }
          let(:complexes) { [] }
        end
      end
    end

  end
end
