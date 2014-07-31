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
        shared_examples_for :check_cell do
          let(:best) { subject.best(spec) }
          it { expect(best.residual.atoms_num).to eq(residue_atoms_num) }
          it { expect(best.specs).to match_array(parts) }
        end

        it_behaves_like :check_cell do
          let(:spec) { dept_methane_base }
          let(:residue_atoms_num) { 1 }
          let(:parts) { [] }
        end

        it_behaves_like :check_cell do
          let(:spec) { dept_bridge_base }
          let(:residue_atoms_num) { 3 }
          let(:parts) { [] }
        end

        it_behaves_like :check_cell do
          let(:spec) { dept_methyl_on_bridge_base }
          let(:residue_atoms_num) { 2 }
          let(:parts) { [dept_bridge_base] }
        end

        it_behaves_like :check_cell do
          let(:spec) { dept_high_bridge_base }
          let(:residue_atoms_num) { 2 }
          let(:parts) { [dept_bridge_base] }
        end

        it_behaves_like :check_cell do
          let(:spec) { dept_dimer_base }
          let(:residue_atoms_num) { 2 }
          let(:parts) { [dept_bridge_base, dept_bridge_base] }
        end

        it_behaves_like :check_cell do
          let(:spec) { dept_methyl_on_dimer_base }
          let(:residue_atoms_num) { 2 }
          let(:parts) { [dept_bridge_base, dept_methyl_on_bridge_base] }
        end

        it_behaves_like :check_cell do
          let(:spec) { dept_extended_bridge_base }
          let(:residue_atoms_num) { 2 }
          let(:parts) { [dept_bridge_base] * 3 }
        end
      end
    end

  end
end
