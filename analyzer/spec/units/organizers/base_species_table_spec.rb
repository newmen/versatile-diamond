require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe BaseSpeciesTable do
      def wrap(spec)
        DependentBaseSpec.new(spec)
      end

      let(:specs) do
        [
          bridge_base,
          dimer_base,
          high_bridge_base,
          methyl_on_bridge_base,
          methyl_on_dimer_base
        ]
      end

      let(:wrapped_specs) { specs.map { |spec| wrap(spec) } }
      let(:cache) { Hash[wrapped_specs.map(&:name).zip(wrapped_specs)] } 
      
      subject { described_class.new(wrapped_specs) }

      describe '#best' do
        shared_examples_for :check_cell do
          let(:best) { subject.best(cache[name]) }
          it { expect(best.residual.links_size).to eq(residue_atoms_num) }
          it { expect(best.specs).to match_array(parts.map { |n| cache[n] }) }
        end

        it_behaves_like :check_cell do
          let(:name) { :bridge }
          let(:residue_atoms_num) { 3 }
          let(:parts) { [] }
        end

        it_behaves_like :check_cell do
          let(:name) { :methyl_on_bridge }
          let(:residue_atoms_num) { 2 }
          let(:parts) { [:bridge] }
        end

        it_behaves_like :check_cell do
          let(:name) { :high_bridge }
          let(:residue_atoms_num) { 2 }
          let(:parts) { [:bridge] }
        end

        it_behaves_like :check_cell do
          let(:name) { :dimer }
          let(:residue_atoms_num) { 2 }
          let(:parts) { [:bridge, :bridge] }
        end

        it_behaves_like :check_cell do
          let(:name) { :methyl_on_dimer }
          let(:residue_atoms_num) { 2 }
          let(:parts) { [:bridge, :methyl_on_bridge] }
        end
      end
    end

  end
end
