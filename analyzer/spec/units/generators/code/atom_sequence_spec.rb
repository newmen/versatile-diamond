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
            expect(seq_spec.original).to eq(sequence)
          end

          it '#delta' do
            expect(seq_spec.delta).to eq(delta)
          end

          it '#addition_atoms' do
            expect(seq_spec.addition_atoms).to eq(additions)
          end
        end

        it_behaves_like :apply_all do
          subject { dept_bridge_base }
          let(:bases) { [dept_dimer_base, dept_methyl_on_bridge_base] }
          let(:specifics) { [dept_activated_bridge] }

          let(:additions) { [] }
          let(:delta) { 0 }
          let(:sequence) do
            [
              bridge_base.atom(:ct),
              bridge_base.atom(:cl),
              bridge_base.atom(:cr),
            ]
          end
        end

        it_behaves_like :apply_all do
          subject { dept_dimer_base }
          let(:bases) { [dept_bridge_base] }
          let(:specifics) { [dept_activated_dimer] }

          let(:additions) { [] }
          let(:delta) { 0 }
          let(:sequence) do
            [
              dimer.atom(:cl),
              dimer.atom(:cr),
            ]
          end
        end
      end

    end
  end
end
