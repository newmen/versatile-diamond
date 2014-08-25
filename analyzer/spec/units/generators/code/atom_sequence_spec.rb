require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe AtomSequence, use: :engine_generator do
        let(:base_specs) { bases + (subject.specific? ? [] : [subject]) }
        let(:specific_specs) { specifics + (subject.specific? ? [subject] : []) }
        let(:generator) do
          stub_generator(base_specs: base_specs, specific_specs: specific_specs)
        end

        let(:code_specie) { generator.specie_class(subject.name) }
        let(:original_specie) { code_specie.original }
        let(:sequence) { generator.sequences_cacher.get(subject) }

        shared_examples_for :apply_all do
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

          it '#delta' do
            expect(sequence.delta).to eq(delta)
          end

          it '#symmetrics' do
            sbcs = sequence.symmetrics(generator, original_specie)
            expect(sbcs.map(&:base_class_name)).to match_array(symmetric_base_classes)
          end
        end

        it_behaves_like :apply_all do
          subject { dept_bridge_base }
          let(:bases) do
            [dept_dimer_base, dept_methyl_on_bridge_base, dept_methyl_on_dimer_base]
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
          let(:delta) { 0 }
          let(:symmetric_base_classes) { [] }
        end

        it_behaves_like :apply_all do
          subject { dept_methyl_on_bridge_base }
          let(:bases) { [dept_bridge_base] }
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
          let(:delta) { 1 }
          let(:symmetric_base_classes) { [] }
        end

        it_behaves_like :apply_all do
          subject { dept_methyl_on_dimer_base }
          let(:bases) { [dept_bridge_base, dept_methyl_on_bridge_base] }
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
          let(:delta) { 0 }
          let(:symmetric_base_classes) { [] }
        end

        describe 'symmetric dimers' do
          subject { dept_dimer_base }
          let(:concept) { subject.spec }
          let(:bases) { [dept_bridge_base] }

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
          let(:short) do
            [
              concept.atom(:cr),
              concept.atom(:cl),
            ]
          end
          let(:major_atoms) { short }
          let(:delta) { 0 }

          it_behaves_like :apply_all do
            let(:specifics) { [dept_twise_incoherent_dimer] }
            let(:symmetric_base_classes) { [] }
          end

          it_behaves_like :apply_all do
            let(:specifics) { [dept_activated_dimer, dept_twise_incoherent_dimer] }

            let(:symmetric_base_classes) do
              ['ParentsSwapWrapper<Empty<SYMMETRIC_DIMER>, OriginalDimer, 0, 1>']
            end
          end

          it_behaves_like :apply_all do
            let(:specifics) do
              [dept_twise_incoherent_dimer, dept_activated_incoherent_dimer]
            end
            let(:symmetric_base_classes) do
              ['ParentsSwapWrapper<Empty<SYMMETRIC_DIMER>, OriginalDimer, 0, 1>']
            end
          end

          it_behaves_like :apply_all do
            let(:specifics) { [dept_bottom_hydrogenated_activated_dimer] }

            let(:symmetric_base_classes) do
              [
                'AtomsSwapWrapper<Empty<SYMMETRIC_DIMER>, 1, 2>',
                'ParentsSwapWrapper<Empty<SYMMETRIC_DIMER>, OriginalDimer, 0, 1>',
                'AtomsSwapWrapper<ParentsSwapWrapper<Empty<SYMMETRIC_DIMER>, OriginalDimer, 0, 1>, 1, 2>'
              ]
            end
          end

          describe 'children as subjects' do
            shared_examples_for :apply_all_for_specific do
              it_behaves_like :apply_all do
                let(:bases) { [dept_bridge_base, dept_dimer_base] }
                let(:specifics) { [specific] }
                let(:symmetric_base_classes) { [empty_class] }
              end
            end

            it_behaves_like :apply_all_for_specific do
              subject { dept_twise_incoherent_dimer }
              let(:specific) { dept_activated_incoherent_dimer }
              let(:short) { [concept.atom(:cr), concept.atom(:cl)] }
              let(:empty_class) do
                'ParentProxy<OriginalDimer, SymmetricDimer, SYMMETRIC_DIMER_CRi_CLi>'
              end
            end

            shared_examples_for :apply_all_for_bottom do
              it_behaves_like :apply_all_for_specific do
                subject { dept_activated_dimer }
                let(:short) { [concept.atom(:cr)] }
              end
            end

            it_behaves_like :apply_all_for_bottom do
              let(:specific) { dept_bottom_hydrogenated_activated_dimer }
              let(:empty_class) { 'AtomsSwapWrapper<Empty<SYMMETRIC_DIMER_CRs>, 4, 5>' }
            end

            it_behaves_like :apply_all_for_bottom do
              let(:specific) { dept_right_bottom_hydrogenated_activated_dimer }
              let(:empty_class) { 'AtomsSwapWrapper<Empty<SYMMETRIC_DIMER_CRs>, 1, 2>' }
            end
          end
        end
      end

    end
  end
end
