require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe BaseSpeciesTable, type: :organizer do

      subject { described_class.new(dependent_base_species) }
      let(:dependent_base_species) do
        [
          dept_methane_base,
          dept_bridge_base,
          dept_dimer_base,
          dept_high_bridge_base,
          dept_methyl_on_bridge_base,
          dept_methyl_on_dimer_base,
          dept_extended_bridge_base
        ]
      end

      describe '#best' do
        shared_examples_for :check_optimal_parents do
          let(:best) { subject.best(spec) }
          it { expect(best.parents).to match_array(parents) }
        end

        it_behaves_like :check_optimal_parents do
          let(:spec) { dept_methane_base }
          let(:parents) { [] }
        end

        it_behaves_like :check_optimal_parents do
          let(:spec) { dept_bridge_base }
          let(:parents) { [] }
        end

        it_behaves_like :check_optimal_parents do
          let(:spec) { dept_methyl_on_bridge_base }
          let(:parents) { [dept_bridge_base] }
        end

        it_behaves_like :check_optimal_parents do
          let(:spec) { dept_high_bridge_base }
          let(:parents) { [dept_bridge_base] }
        end

        it_behaves_like :check_optimal_parents do
          let(:spec) { dept_dimer_base }
          let(:parents) { [dept_bridge_base, dept_bridge_base] }
        end

        it_behaves_like :check_optimal_parents do
          let(:spec) { dept_methyl_on_dimer_base }
          let(:parents) { [dept_bridge_base, dept_methyl_on_bridge_base] }
        end

        it_behaves_like :check_optimal_parents do
          let(:spec) { dept_extended_bridge_base }
          let(:parents) { [dept_bridge_base] * 3 }
        end
      end
    end

  end
end
