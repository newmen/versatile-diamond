require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe AtomSequence, use: :engine_generator do
        shared_examples_for :apply_all do
          let(:base_specs) { bases + (subject.specific? ? [] : [subject]) }
          let(:specific_specs) { specifics + (subject.specific? ? [subject] : []) }
          let(:analysis_results) do
            stub_results(base_specs: base_specs, specific_specs: specific_specs)
          end

          before { analysis_results }

          let(:seq_spec) { described_class.new(subject) }

          it '#original' do
            expect(seq_spec.original).to eq(original)
          end

          it '#short' do
            expect(seq_spec.short).to eq(short)
          end

          it '#delta' do
            expect(seq_spec.delta).to eq(delta)
          end
        end

        it_behaves_like :apply_all do
          subject { dept_bridge_base }
          let(:bases) { [dept_dimer_base, dept_methyl_on_bridge_base] }
          let(:specifics) { [dept_activated_bridge] }

          let(:delta) { 0 }
          let(:original) do
            [
              bridge_base.atom(:ct),
              bridge_base.atom(:cl),
              bridge_base.atom(:cr),
            ]
          end
          let(:short) { original }
        end

        it_behaves_like :apply_all do
          subject { dept_dimer_base }
          let(:bases) { [dept_bridge_base] }
          let(:specifics) { [dept_activated_dimer] }

          let(:delta) { 0 }
          let(:original) do
            [
              dimer_base.atom(:cr),
              bridge_base.atom(:cl),
              bridge_base.atom(:cr),
              dimer_base.atom(:cl),
              bridge_base.atom(:cl),
              bridge_base.atom(:cr),
            ]
          end

          let(:short) do
            [
              dimer_base.atom(:cr),
              dimer_base.atom(:cl),
            ]
          end
        end

        it_behaves_like :apply_all do
          subject { dept_methyl_on_bridge_base }
          let(:bases) { [dept_bridge_base] }
          let(:specifics) { [dept_activated_methyl_on_bridge] }

          let(:delta) { 1 }
          let(:original) do
            [
              methyl_on_bridge_base.atom(:cm),
              methyl_on_bridge_base.atom(:cb),
              bridge_base.atom(:cl),
              bridge_base.atom(:cr),
            ]
          end
          let(:short) do
            [
              methyl_on_bridge_base.atom(:cb),
              methyl_on_bridge_base.atom(:cm),
            ]
          end
        end
      end

    end
  end
end
