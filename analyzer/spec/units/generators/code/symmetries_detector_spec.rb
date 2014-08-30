require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe SymmetriesDetector, use: :engine_generator do
        shared_examples_for :check_symmetry do
          let(:detector) { generator.detectors_cacher.get(subject) }
          let(:generator) do
            stub_generator(base_specs: bases, specific_specs: specifics)
          end
          let(:symmetry_classes_names) do
            detector.symmetry_classes.map(&:base_class_name)
          end

          before { generator }

          it { expect(symmetry_classes_names).to match_array(symmetry_classes) }
          it { expect(detector.use_parent_symmetry?).to eq(use_parent_symmetry) }
        end

        it_behaves_like :check_symmetry do
          subject { dept_bridge_base }
          let(:bases) do
            [
              dept_bridge_base,
              dept_dimer_base,
              dept_methyl_on_bridge_base,
              dept_methyl_on_dimer_base
            ]
          end
          let(:specifics) { [dept_activated_bridge] }
          let(:symmetry_classes) { [] }
          let(:use_parent_symmetry) { false }
        end

        it_behaves_like :check_symmetry do
          subject { dept_methyl_on_bridge_base }
          let(:bases) { [dept_bridge_base, dept_methyl_on_bridge_base] }
          let(:specifics) { [dept_activated_methyl_on_bridge] }
          let(:symmetry_classes) { [] }
          let(:use_parent_symmetry) { false }
        end

        it_behaves_like :check_symmetry do
          subject { dept_methyl_on_dimer_base }
          let(:bases) do
            [dept_bridge_base, dept_methyl_on_dimer_base, dept_methyl_on_bridge_base]
          end
          let(:specifics) { [dept_activated_methyl_on_dimer] }
          let(:symmetry_classes) { [] }
          let(:use_parent_symmetry) { false }
        end

        describe 'symmetric dimers' do
          subject { dept_dimer_base }
          let(:bases) { [dept_bridge_base, dept_dimer_base] }
          let(:use_parent_symmetry) { false }

          it_behaves_like :check_symmetry do
            let(:specifics) { [dept_twise_incoherent_dimer] }
            let(:symmetry_classes) { [] }
          end

          it_behaves_like :check_symmetry do
            let(:specifics) { [dept_activated_dimer, dept_twise_incoherent_dimer] }
            let(:symmetry_classes) do
              ['ParentsSwapWrapper<Empty<DIMER>, OriginalDimer, 0, 1>']
            end
          end

          it_behaves_like :check_symmetry do
            let(:specifics) do
              [dept_twise_incoherent_dimer, dept_activated_incoherent_dimer]
            end
            let(:symmetry_classes) do
              ['ParentsSwapWrapper<Empty<DIMER>, OriginalDimer, 0, 1>']
            end
          end

          it_behaves_like :check_symmetry do
            let(:specifics) { [dept_bottom_hydrogenated_activated_dimer] }
            let(:symmetry_classes) do
              [
                'AtomsSwapWrapper<Empty<DIMER>, 1, 2>',
                'ParentsSwapWrapper<Empty<DIMER>, OriginalDimer, 0, 1>',
                'AtomsSwapWrapper<ParentsSwapWrapper<Empty<DIMER>, OriginalDimer, 0, 1>, 1, 2>'
              ]
            end
          end
        end

        describe 'dimer children' do
          let(:bases) { [dept_bridge_base, dept_dimer_base] }

          describe 'incoherent dimer' do
            let(:specifics) do
              [dept_activated_incoherent_dimer, dept_twise_incoherent_dimer]
            end

            it_behaves_like :check_symmetry do
              subject { dept_twise_incoherent_dimer }
              let(:symmetry_classes) do
                ['ParentProxy<OriginalDimer, SymmetricDimer, DIMER_CLi_CRi>']
              end
              let(:use_parent_symmetry) { false }
            end

            it_behaves_like :check_symmetry do
              subject { dept_activated_incoherent_dimer }
              let(:symmetry_classes) { [] }
              let(:use_parent_symmetry) { true }
            end
          end

          describe 'activated dimer' do
            subject { dept_activated_dimer }
            let(:specifics) { [dept_activated_dimer, specific] }
            let(:use_parent_symmetry) { true }

            it_behaves_like :check_symmetry do
              let(:specific) { dept_bottom_hydrogenated_activated_dimer }
              let(:symmetry_classes) { ['AtomsSwapWrapper<Empty<DIMER_CRs>, 4, 5>'] }
            end

            it_behaves_like :check_symmetry do
              let(:specific) { dept_right_bottom_hydrogenated_activated_dimer }
              let(:symmetry_classes) { ['AtomsSwapWrapper<Empty<DIMER_CRs>, 1, 2>'] }
            end
          end
        end
      end

    end
  end
end
