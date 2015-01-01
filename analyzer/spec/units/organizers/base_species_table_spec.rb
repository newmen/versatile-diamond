require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe BaseSpeciesTable, type: :organizer do
      subject { described_class.new(dependent_base_species) }

      describe '#best' do
        shared_examples_for :check_optimal_parents do
          let(:best) { subject.best(spec) }
          it { expect(best.parents.map(&:original)).to match_array(parents) }
        end

        shared_examples_for :default_check_optimal_parents do
          it_behaves_like :check_optimal_parents do
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
          end
        end

        it_behaves_like :default_check_optimal_parents do
          let(:spec) { dept_methane_base }
          let(:parents) { [] }
        end

        it_behaves_like :default_check_optimal_parents do
          let(:spec) { dept_bridge_base }
          let(:parents) { [] }
        end

        it_behaves_like :default_check_optimal_parents do
          let(:spec) { dept_methyl_on_bridge_base }
          let(:parents) { [dept_bridge_base] }
        end

        it_behaves_like :default_check_optimal_parents do
          let(:spec) { dept_high_bridge_base }
          let(:parents) { [dept_bridge_base] }
        end

        it_behaves_like :default_check_optimal_parents do
          let(:spec) { dept_dimer_base }
          let(:parents) { [dept_bridge_base, dept_bridge_base] }
        end

        it_behaves_like :default_check_optimal_parents do
          let(:spec) { dept_methyl_on_dimer_base }
          let(:parents) { [dept_bridge_base, dept_methyl_on_bridge_base] }
        end

        it_behaves_like :default_check_optimal_parents do
          let(:spec) { dept_extended_bridge_base }
          let(:parents) { [dept_bridge_base] * 3 }
        end

        it_behaves_like :check_optimal_parents do
          let(:dependent_base_species) do
            [
              dept_bridge_base,
              dept_methyl_on_bridge_base,
              dept_dimer_base,
              dept_methyl_on_dimer_base,
              dept_intermed_migr_down_half_base,
              spec
            ]
          end
          let(:spec) { dept_intermed_migr_down_full_base }
          let(:parents) { [dept_methyl_on_bridge_base, dept_methyl_on_dimer_base] }
        end

        it_behaves_like :check_optimal_parents do
          let(:dependent_base_species) do
            [dept_bridge_base, dept_methyl_on_bridge_base, spec]
          end
          let(:spec) { dept_methyl_on_half_extended_bridge_base }
          let(:parents) { [dept_bridge_base, dept_methyl_on_bridge_base] }
        end
      end
    end

  end
end
