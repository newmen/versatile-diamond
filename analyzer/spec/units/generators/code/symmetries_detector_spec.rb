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

          before { generator }

          it '#symmetry_classes' do
            sbcs = detector.symmetry_classes
            expect(sbcs.map(&:base_class_name)).to match_array(base_classes)
          end
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
          let(:base_classes) { [] }
        end

        it_behaves_like :check_symmetry do
          subject { dept_methyl_on_bridge_base }
          let(:bases) { [dept_bridge_base, dept_methyl_on_bridge_base] }
          let(:specifics) { [dept_activated_methyl_on_bridge] }
          let(:base_classes) { [] }
        end

        it_behaves_like :check_symmetry do
          subject { dept_methyl_on_dimer_base }
          let(:bases) do
            [dept_bridge_base, dept_methyl_on_dimer_base, dept_methyl_on_bridge_base]
          end
          let(:specifics) { [dept_activated_methyl_on_dimer] }
          let(:base_classes) { [] }
        end

        describe 'symmetric dimers' do
          subject { dept_dimer_base }
          let(:bases) { [dept_bridge_base, dept_dimer_base] }

          it_behaves_like :check_symmetry do
            let(:specifics) { [dept_twise_incoherent_dimer] }
            let(:base_classes) { [] }
          end

          it_behaves_like :check_symmetry do
            let(:specifics) { [dept_activated_dimer, dept_twise_incoherent_dimer] }
            let(:base_classes) do
              ['ParentsSwapWrapper<Empty<DIMER>, OriginalDimer, 0, 1>']
            end
          end

          it_behaves_like :check_symmetry do
            let(:specifics) do
              [dept_twise_incoherent_dimer, dept_activated_incoherent_dimer]
            end
            let(:base_classes) do
              ['ParentsSwapWrapper<Empty<DIMER>, OriginalDimer, 0, 1>']
            end
          end

          it_behaves_like :check_symmetry do
            let(:specifics) { [dept_bottom_hydrogenated_activated_dimer] }
            let(:base_classes) do
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

          it_behaves_like :check_symmetry do
            subject { dept_twise_incoherent_dimer }
            let(:specifics) do
              [dept_activated_incoherent_dimer, dept_twise_incoherent_dimer]
            end
            let(:base_classes) do
              ['ParentProxy<OriginalDimer, SymmetricDimer, DIMER_CLi_CRi>']
            end
          end

          describe 'activated dimer' do
            subject { dept_activated_dimer }

            it_behaves_like :check_symmetry do
              let(:specifics) do
                [dept_activated_dimer, dept_bottom_hydrogenated_activated_dimer]
              end
              let(:base_classes) { ['AtomsSwapWrapper<Empty<DIMER_CRs>, 4, 5>'] }
            end

            it_behaves_like :check_symmetry do
              let(:specifics) do
                [dept_activated_dimer, dept_right_bottom_hydrogenated_activated_dimer]
              end
              let(:base_classes) { ['AtomsSwapWrapper<Empty<DIMER_CRs>, 1, 2>'] }
            end
          end
        end
      end

    end
  end
end
