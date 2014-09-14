require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe AtomSequence, use: :engine_generator do
        shared_examples_for :apply_all do
          let(:sequence) { generator.sequences_cacher.get(subject) }
          let(:generator) do
            stub_generator(base_specs: bases, specific_specs: specifics)
          end

          before { generator }

          it '#original' do
            expect(sequence.original).to eq(original)
          end

          it '#short' do
            expect(sequence.short).to eq(short)
          end

          it '#major_atoms' do
            expect(sequence.major_atoms).to eq(major_atoms)
          end

          it '#addition_atoms' do
            expect(sequence.addition_atoms).to eq(addition_atoms)
          end

          it '#delta' do
            expect(sequence.delta).to eq(addition_atoms.size)
          end
        end

        it_behaves_like :apply_all do
          subject { dept_bridge_base }
          let(:bases) do
            [
              subject,
              dept_dimer_base,
              dept_methyl_on_bridge_base,
              dept_methyl_on_dimer_base
            ]
          end
          let(:specifics) { [dept_activated_bridge] }

          let(:original) do
            [
              bridge_base.atom(:ct),
              bridge_base.atom(:cl),
              bridge_base.atom(:cr),
            ]
          end
          let(:short) { original }
          let(:major_atoms) { original }
          let(:addition_atoms) { [] }
        end

        it_behaves_like :apply_all do
          subject { dept_methyl_on_bridge_base }
          let(:bases) { [dept_bridge_base, subject] }
          let(:specifics) { [dept_activated_methyl_on_bridge] }

          let(:original) do
            [
              methyl_on_bridge_base.atom(:cm),
              methyl_on_bridge_base.atom(:cb),
              methyl_on_bridge_base.atom(:cl),
              methyl_on_bridge_base.atom(:cr),
            ]
          end
          let(:short) do
            [
              methyl_on_bridge_base.atom(:cb),
              methyl_on_bridge_base.atom(:cm),
            ]
          end
          let(:major_atoms) { [methyl_on_bridge_base.atom(:cb)] }
          let(:addition_atoms) { [methyl_on_bridge_base.atom(:cm)] }
        end

        it_behaves_like :apply_all do
          subject { dept_methyl_on_dimer_base }
          let(:bases) { [dept_bridge_base, dept_methyl_on_bridge_base, subject] }
          let(:specifics) { [dept_activated_methyl_on_dimer] }

          let(:original) do
            [
              methyl_on_dimer_base.atom(:cm),
              methyl_on_dimer_base.atom(:cr),
              methyl_on_dimer_base.atom(:crb),
              methyl_on_dimer_base.atom(:_cr0),
              methyl_on_dimer_base.atom(:cl),
              methyl_on_dimer_base.atom(:clb),
              methyl_on_dimer_base.atom(:_cr1),
            ]
          end
          let(:short) do
            [
              methyl_on_dimer_base.atom(:cr),
              methyl_on_dimer_base.atom(:cl),
            ]
          end
          let(:major_atoms) { short }
          let(:addition_atoms) { [] }
        end

        it_behaves_like :apply_all do
          subject { dept_cross_bridge_on_bridges_base }
          let(:bases) { [dept_bridge_base, dept_methyl_on_bridge_base, subject] }
          let(:specifics) { [] }

          let(:original) do
            [
              cross_bridge_on_bridges_base.atom(:cm),
              cross_bridge_on_bridges_base.atom(:ctl),
              cross_bridge_on_bridges_base.atom(:cl),
              cross_bridge_on_bridges_base.atom(:cr),
              cross_bridge_on_bridges_base.atom(:cm),
              cross_bridge_on_bridges_base.atom(:ctr),
              cross_bridge_on_bridges_base.atom(:_cr0),
              cross_bridge_on_bridges_base.atom(:_cl0),
            ]
          end
          let(:short) do
            [
              cross_bridge_on_bridges_base.atom(:ctl),
              cross_bridge_on_bridges_base.atom(:ctr),
              cross_bridge_on_bridges_base.atom(:cm),
            ]
          end
          let(:major_atoms) { short }
          let(:addition_atoms) { [] }
        end

        it_behaves_like :apply_all do
          subject { dept_three_bridges_base }
          let(:bases) { [dept_bridge_base, subject] }
          let(:specifics) { [] }

          let(:original) do
            [
              three_bridges_base.atom(:tt),
              three_bridges_base.atom(:cc),
              three_bridges_base.atom(:ct),
              three_bridges_base.atom(:ct),
              three_bridges_base.atom(:cr),
              three_bridges_base.atom(:cl),
              three_bridges_base.atom(:_ct0),
              three_bridges_base.atom(:cc),
              three_bridges_base.atom(:_cl0),
            ]
          end
          let(:short) do
            [
              three_bridges_base.atom(:ct),
              three_bridges_base.atom(:cc),
            ]
          end
          let(:major_atoms) { short }
          let(:addition_atoms) { [] }
        end

        describe 'symmetric dimers' do
          let(:concept) { subject.spec }
          let(:bases) { [dept_bridge_base, dept_dimer_base] }

          let(:original) do
            [
              concept.atom(:cr),
              concept.atom(:crb),
              concept.atom(:_cr0),
              concept.atom(:cl),
              concept.atom(:_cr1),
              concept.atom(:clb),
            ]
          end
          let(:major_atoms) { short }
          let(:addition_atoms) { [] }

          it_behaves_like :apply_all do
            subject { dept_dimer_base }
            let(:specifics) { [dept_activated_dimer] }
            let(:short) { [concept.atom(:cr), concept.atom(:cl)] }
          end

          it_behaves_like :apply_all do
            subject { dept_twise_incoherent_dimer }
            let(:specifics) do
              [dept_activated_incoherent_dimer, dept_twise_incoherent_dimer]
            end
            let(:short) { [concept.atom(:cr), concept.atom(:cl)] }
          end

          it_behaves_like :apply_all do
            subject { dept_activated_dimer }
            let(:specifics) do
              [dept_activated_dimer, dept_bottom_hydrogenated_activated_dimer]
            end
            let(:short) { [concept.atom(:cr)] }
          end
        end
      end

    end
  end
end
