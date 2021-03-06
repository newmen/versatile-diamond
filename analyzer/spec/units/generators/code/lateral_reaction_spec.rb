require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe LateralReaction, type: :code do
        let(:generator) do
          stub_generator(
            typical_reactions: [dept_dimer_formation],
            lateral_reactions: lateral_reactions)
        end

        subject { described_class.new(generator, target) }

        describe 'basic properties' do
          let(:target) { dept_end_lateral_df }
          let(:lateral_reactions) { [target] }

          it_behaves_like :check_main_names do
            let(:class_name) { 'ForwardDimerFormationEndLateral' }
            let(:enum_name) { 'FORWARD_DIMER_FORMATION_END_LATERAL' }
            let(:file_name) { 'forward_dimer_formation_end_lateral' }
            let(:print_name) { end_lateral_df.name }
          end

          it_behaves_like :check_gas_concentrations do
            let(:env_concs) { [] }
          end
        end

        describe '#base_class_name' do
          describe 'several lateral reactions' do
            let(:lateral_reactions) { [dept_end_lateral_df, dept_middle_lateral_df] }

            it_behaves_like :check_base_class_name do
              let(:target) { dept_end_lateral_df }
              let(:outer_class_name) { 'ConcretizableRole' }
              let(:templ_args) do
                ['SingleLateral', 'FORWARD_DIMER_FORMATION_END_LATERAL', 1]
              end
            end

            it_behaves_like :check_base_class_name do
              let(:target) { dept_middle_lateral_df }
              let(:outer_class_name) { 'MultiLateral' }
              let(:templ_args) { ['FORWARD_DIMER_FORMATION_MIDDLE_LATERAL', 2] }
            end
          end

          describe 'one lateral reaction' do
            let(:lateral_reactions) { [dept_middle_lateral_df] }
            it_behaves_like :check_base_class_name do
              let(:target) { dept_middle_lateral_df }
              let(:outer_class_name) { 'MultiLateral' }
              let(:templ_args) { ['FORWARD_DIMER_FORMATION_MIDDLE_LATERAL', 2] }
            end
          end
        end

        describe '#internal_chunks' do
          shared_examples_for :check_internal_chunks do
            it { expect(subject.internal_chunks).to eq(internal_chunks) }
          end

          it_behaves_like :check_internal_chunks do
            let(:lateral_reactions) { [target] }
            let(:target) { dept_end_lateral_df }
            let(:internal_chunks) { [end_chunk] }
          end

          it_behaves_like :check_internal_chunks do
            let(:lateral_reactions) { [dept_end_lateral_df, target] }
            let(:target) { dept_middle_lateral_df }
            let(:internal_chunks) { [end_chunk] * 2 }
          end
        end

        describe '#concretizable?' do
          let(:lateral_reactions) { [target] }

          describe 'small' do
            let(:target) { dept_end_lateral_df }
            it { expect(subject.concretizable?).to be_truthy }
          end

          describe 'big' do
            let(:target) { dept_middle_lateral_df }
            it { expect(subject.concretizable?).to be_falsey }
          end
        end

        describe '#use_relation?' do
          let(:lateral_reactions) { [target] }

          describe 'dimers row' do
            let(:target) { dept_end_lateral_df }
            it { expect(subject.use_relation?(param_100_cross)).to be_truthy }
            it { expect(subject.use_relation?(param_100_front)).to be_falsey }
          end

          describe 'multi bridges' do
            let(:target) { dept_small_ab_lateral_sdf }
            it { expect(subject.use_relation?(param_100_cross)).to be_truthy }
            it { expect(subject.use_relation?(param_100_front)).to be_truthy }
          end
        end
      end

    end
  end
end
