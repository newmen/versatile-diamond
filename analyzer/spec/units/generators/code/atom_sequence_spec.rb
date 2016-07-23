require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe AtomSequence, use: :engine_generator do
        shared_examples_for :apply_all do
          def at_to_kns(atom)
            subject.spec.keyname(atom)
          end

          let(:sequence) { generator.sequences_cacher.get(subject) }
          let(:generator) do
            stub_generator(base_specs: bases, specific_specs: specifics)
          end

          before { generator }

          let(:original_keynames) { sequence.original.map(&method(:at_to_kns)) }
          let(:short_keynames) { sequence.short.map(&method(:at_to_kns)) }
          let(:major_keynames) { sequence.major_atoms.map(&method(:at_to_kns)) }
          let(:addition_keynames) { sequence.addition_atoms.map(&method(:at_to_kns)) }

          # each method should not change the state of sequence
          it '#original && #short && #major_atoms && #addition_atoms && #delta' do
            expect(original_keynames).to eq(original)
            expect(short_keynames).to eq(short)
            expect(major_keynames).to eq(major_atoms)
            expect(addition_keynames).to eq(addition_atoms)
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

          let(:original) { %i(ct cl cr) }
          let(:short) { original }
          let(:major_atoms) { original }
          let(:addition_atoms) { [] }
        end

        describe 'like methyl on bridge' do
          let(:original) { %i(cm cb cl cr) }
          let(:short) { %i(cb cm) }
          let(:major_atoms) { %i(cb) }
          let(:addition_atoms) { %i(cm) }

          it_behaves_like :apply_all do
            subject { dept_methyl_on_bridge_base }
            let(:bases) { [dept_bridge_base, subject] }
            let(:specifics) { [dept_activated_methyl_on_bridge] }
          end

          it_behaves_like :apply_all do
            subject { dept_high_bridge_base }
            let(:bases) { [dept_bridge_base, subject] }
            let(:specifics) { [] }
          end
        end

        describe 'like vinyl on bridge' do
          let(:original) { %i(c2 c1 cb cl cr) }
          let(:short) { %i(c1 c2) }
          let(:major_atoms) { %i(c1) }
          let(:addition_atoms) { %i(c2) }

          it_behaves_like :apply_all do
            subject { dept_vinyl_on_bridge_base }
            let(:bases) { [dept_bridge_base, dept_methyl_on_bridge_base, subject] }
            let(:specifics) { [] }
          end

          it_behaves_like :apply_all do
            subject { dept_very_high_bridge_base }
            let(:bases) { [dept_bridge_base, dept_high_bridge_base, subject] }
            let(:specifics) { [] }
          end
        end

        it_behaves_like :apply_all do
          subject { dept_incoherent_very_high_bridge }
          before { subject.replace_base_spec(dept_high_bridge_base) }
          let(:specifics) { [subject] }
          let(:bases) do
            [dept_bridge_base, dept_high_bridge_base, dept_vinyl_on_bridge_base]
          end

          let(:original) { %i(c2 cm cb cl cr) }
          let(:short) { %i(cm c2) }
          let(:major_atoms) { %i(cm) }
          let(:addition_atoms) { %i(c2) }
        end

        it_behaves_like :apply_all do
          subject { dept_methyl_on_dimer_base }
          let(:bases) { [dept_bridge_base, dept_methyl_on_bridge_base, subject] }
          let(:specifics) { [dept_activated_methyl_on_dimer] }

          let(:original) { %i(cm cr crb _cr0 cl clb _cr1) }
          let(:short) { %i(cr cl) }
          let(:major_atoms) { short }
          let(:addition_atoms) { [] }
        end

        it_behaves_like :apply_all do
          subject { dept_cross_bridge_on_bridges_base }
          let(:bases) { [dept_bridge_base, dept_methyl_on_bridge_base, subject] }
          let(:specifics) { [] }

          let(:original) { %i(cm ctl cl cr cm ctr _cr0 _cl0) }
          let(:short) { %i(ctl ctr cm) }
          let(:major_atoms) { short }
          let(:addition_atoms) { [] }
        end

        it_behaves_like :apply_all do
          subject { dept_cross_bridge_on_dimers_base }
          let(:bases) { [dept_methyl_on_dimer_base, subject] }
          let(:specifics) { [] }

          let(:original) do
            %i(cm ctl csl crb _cr1 clb _cr0 cm ctr csr _cr2 _clb0 _cr3 _crb0)
          end
          let(:short) { %i(ctl ctr csl csr cm) }
          let(:major_atoms) { short }
          let(:addition_atoms) { [] }
        end

        it_behaves_like :apply_all do
          subject { dept_three_bridges_base }
          let(:bases) { [dept_bridge_base, subject] }
          let(:specifics) { [] }

          let(:original) { %i(tt cc ct _ct0 cc _cl0 ct cr cl) }
          let(:short) { %i(ct cc) }
          let(:major_atoms) { short }
          let(:addition_atoms) { [] }
        end

        describe 'symmetric dimers' do
          let(:concept) { subject.spec }
          let(:bases) { [dept_bridge_base, dept_dimer_base] }

          let(:major_atoms) { short }
          let(:addition_atoms) { [] }

          it_behaves_like :apply_all do
            subject { dept_dimer_base }
            let(:original) { %i(cl _cr1 clb cr crb _cr0) }
            let(:short) { %i(cl cr) }
            let(:specifics) { [dept_activated_dimer] }
          end

          it_behaves_like :apply_all do
            subject { dept_twise_incoherent_dimer }
            let(:original) { %i(cl clb _cr1 cr _cr0 crb) }
            let(:short) { %i(cl cr) }
            let(:specifics) do
              [dept_activated_incoherent_dimer, dept_twise_incoherent_dimer]
            end
          end

          it_behaves_like :apply_all do
            subject { dept_activated_dimer }
            let(:original) { %i(cl clb _cr1 cr _cr0 crb) }
            let(:short) { %i(cr) }
            let(:specifics) do
              [dept_activated_dimer, dept_bottom_hydrogenated_activated_dimer]
            end
          end
        end
      end

    end
  end
end
