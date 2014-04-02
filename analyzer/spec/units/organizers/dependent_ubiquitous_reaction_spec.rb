require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe DependentUbiquitousReaction do
      def wrap(reaction)
        described_class.new(reaction)
      end

      subject { wrap(surface_activation) }

      describe '#termination' do
        it { expect(subject.termination).to eq(adsorbed_h) }
      end

      describe '#organize_dependencies!' do
        def typical(reaction)
          DependentTypicalReaction.new(reaction)
        end

        shared_examples_for :cover_just_one do
          let(:another_reactions) do
            [
              methyl_desorption,
              dimer_formation,
              hydrogen_migration
            ].map { |r| typical(r) }
          end

          before do
            target.organize_dependencies!(another_reactions + [complex])
          end

          describe '#complexes' do
            it { expect(target.complexes).to eq([complex]) }
          end
        end

        it_behaves_like :cover_just_one do
          let(:target) { subject }
          let(:complex) { typical(methyl_activation) }
        end

        it_behaves_like :cover_just_one do
          let(:target) { wrap(surface_deactivation) }
          let(:complex) { typical(methyl_deactivation) }
        end
      end
    end

  end
end
