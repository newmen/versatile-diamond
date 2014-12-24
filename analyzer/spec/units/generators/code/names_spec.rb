require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe Names, type: :code do
        let(:generator) do
          stub_generator(
            ubiquitous_reactions: [dept_surface_activation],
            typical_reactions: [dept_methyl_activation, dept_dimer_formation],
            lateral_reactions: [dept_end_lateral_df])
        end

        subject { generator.names }

        describe '#base_species_num' do
          it { expect(subject.base_species_num).to eq(3) }
        end

        describe '#specific_species_num' do
          it { expect(subject.specific_species_num).to eq(2) }
        end

        describe '#ubiquitous_reactions_num' do
          it { expect(subject.ubiquitous_reactions_num).to eq(2) }
        end

        describe '#typical_reactions_num' do
          it { expect(subject.typical_reactions_num).to eq(1) }
        end

        describe '#lateral_reactions_num' do
          it { expect(subject.typical_reactions_num).to eq(1) }
        end
      end

    end
  end
end
