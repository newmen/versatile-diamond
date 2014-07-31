require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe AtomSequence, use: :engine_generator do
        shared_examples_for :apply_all do
          let(:base_specs) { bases + (subject.specific? ? [] : [subject]) }
          let(:specific_specs) { specifics + (subject.specific? ? [subject] : []) }
          let(:generator) do
            stub_generator(base_specs: base_specs, specific_specs: specific_specs)
          end

          before { generator }

          let(:sequence) { generator.sequences_cacher.get(subject) }

          it '#original' do
            expect(sequence.original).to eq(original)
          end

          it '#short' do
            expect(sequence.short).to eq(short)
          end

          it '#delta' do
            expect(sequence.delta).to eq(delta)
          end

          let(:code_specie) { generator.specie_class(subject.name) }
          let(:original_specie) { code_specie.original }

          it '#symmetrics' do
            sbcs = sequence.symmetrics(generator, original_specie)
            expect(sbcs.map(&:base_class_name)).to match_array(symmetric_base_classes)
          end
        end

        it_behaves_like :apply_all do
          subject { dept_bridge_base }
          let(:bases) { [dept_dimer_base, dept_methyl_on_bridge_base] }
          let(:specifics) { [dept_activated_bridge] }

          let(:original) do
            [
              bridge_base.atom(:ct),
              bridge_base.atom(:cl),
              bridge_base.atom(:cr),
            ]
          end
          let(:short) { original }
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
              methyl_on_dimer_base.atom(:_cr0),
              methyl_on_dimer_base.atom(:clb),
              methyl_on_dimer_base.atom(:cl),
              methyl_on_dimer_base.atom(:_cr1),
              methyl_on_dimer_base.atom(:_cl0),
            ]
          end
          let(:short) do
            [
              methyl_on_dimer_base.atom(:cr),
              methyl_on_dimer_base.atom(:cl),
            ]
          end
          let(:delta) { 0 }
          let(:symmetric_base_classes) { [] }
        end

        describe 'symmetric dimers' do
          subject { dept_dimer_base }
          let(:bases) { [dept_bridge_base] }

          let(:original) do
            [
              dimer_base.atom(:cr),
              dimer_base.atom(:clb),
              dimer_base.atom(:_cr0),
              dimer_base.atom(:cl),
              dimer_base.atom(:_cl0),
              dimer_base.atom(:_cr1),
            ]
          end
          let(:short) do
            [
              dimer_base.atom(:cr),
              dimer_base.atom(:cl),
            ]
          end
          let(:delta) { 0 }

          it_behaves_like :apply_all do
            let(:specifics) { [dept_activated_dimer] }

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
        end
      end

    end
  end
end
