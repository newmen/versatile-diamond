require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe TypicalReaction, type: :code do
        let(:generator) do
          stub_generator(
            typical_reactions: [target],
            lateral_reactions: lateral_reactions)
        end

        let(:lateral_reactions) { [] }
        let(:target) { dept_dimer_formation }
        subject { described_class.new(generator, target) }

        it_behaves_like :check_main_names do
          let(:class_name) { 'ForwardDimerFormation' }
          let(:enum_name) { 'FORWARD_DIMER_FORMATION' }
          let(:file_name) { 'forward_dimer_formation' }
          let(:print_name) { dimer_formation.name }
        end

        it_behaves_like :check_gas_concentrations do
          let(:env_concs) { [] }
        end

        describe '#base_class_name' do
          it_behaves_like :check_base_class_name do
            let(:outer_class_name) { 'Typical' }
            let(:templ_args) { ['FORWARD_DIMER_FORMATION', 2] }
          end

          it_behaves_like :check_base_class_name do
            let(:lateral_reactions) { [dept_end_lateral_df] }
            let(:outer_class_name) { 'ConcretizableRole' }
            let(:templ_args) { ['Central', 'FORWARD_DIMER_FORMATION', 2] }
          end
        end

        describe '#sidepiece_species' do
          it { expect(subject.sidepiece_species).to be_empty }
        end

        describe '#target_index' do
          describe 'without index' do
            let(:target) { dept_incoherent_dimer_drop }
            it { expect(subject.target_index(idd_source.first)).to be_nil }
          end

          describe 'with index 0' do
            it { expect(subject.target_index(df_source.last)).to eq(0) }
          end

          describe 'with index 1' do
            it { expect(subject.target_index(df_source.first)).to eq(1) }
          end
        end
      end

    end
  end
end
