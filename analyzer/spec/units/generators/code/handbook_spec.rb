require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe Handbook, use: :engine_generator do
        subject { described_class.new(generator) }

        let(:ubiquitous_reactions) { [] }
        let(:typical_reactions) { [] }
        let(:lateral_reactions) { [] }
        let(:generator) do
          stub_generator(
            ubiquitous_reactions: ubiquitous_reactions,
            typical_reactions: typical_reactions,
            lateral_reactions: lateral_reactions)
        end

        describe '#ubiquitous_reactions_exists?' do
          describe 'default' do
            it { expect(subject.ubiquitous_reactions_exists?).to be_falsey }
          end

          describe 'just typical' do
            let(:typical_reactions) { [dept_methyl_activation] }
            it { expect(subject.ubiquitous_reactions_exists?).to be_falsey }
          end

          describe 'presented' do
            let(:ubiquitous_reactions) { [dept_surface_activation] }
            it { expect(subject.ubiquitous_reactions_exists?).to be_truthy }
          end
        end

        describe '#lateral_reactions_exists?' do
          describe 'default' do
            it { expect(subject.lateral_reactions_exists?).to be_falsey }
          end

          describe 'just typical' do
            let(:typical_reactions) { [dept_dimer_formation] }
            it { expect(subject.lateral_reactions_exists?).to be_falsey }
          end

          describe 'presented' do
            let(:lateral_reactions) { [dept_end_lateral_df] }
            it { expect(subject.lateral_reactions_exists?).to be_truthy }
          end
        end
      end

    end
  end
end
