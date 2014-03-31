require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe Reaction do

      describe '#type' do
        it { expect(methyl_desorption.type).to eq(:forward) }
        it { expect(hydrogen_migration.type).to eq(:forward) }
        it { expect(dimer_formation.type).to eq(:forward) }
        it { expect(methyl_incorporation.type).to eq(:forward) }

        it { expect(methyl_desorption.reverse.type).to eq(:reverse) }
      end

      shared_examples_for 'check duplicate property' do
        it { expect(subject.name).to match(/tail$/) }
        it { expect(subject.reverse.name).to match(/tail$/) }

        it { expect(subject.source).not_to eq(df_source) }
        it { expect(subject.source.first).not_to eq(df_source.first) }
        it { expect(subject.products).not_to eq(df_products) }
        it { expect(subject.products.first).not_to eq(df_products.first) }
        it { expect(subject.products.last).not_to eq(df_products.last) }

        shared_examples_for 'child changes too' do
          %w(enthalpy activation rate).each do |prop|
            describe "children setup #{prop}" do
              before(:each) do
                child # makes a child
                reaction.send(:"#{prop}=", 456)
              end
              it { expect(child.send(prop)).to eq(456) }
            end
          end
        end

        it_behaves_like 'child changes too' do
          let(:reaction) { dimer_formation }
          let(:child) { subject }
        end

        it_behaves_like 'child changes too' do
          let(:reaction) { dimer_formation.reverse }
          let(:child) { subject.reverse }
        end
      end

      describe '#as' do
        shared_examples_for 'forward and reverse' do
          let(:name) { 'dimer formation' }
          before(:each) do
            subject.as(:forward).rate = 1
            subject.as(:forward).reverse.rate = 2
          end

          it { expect(subject.as(:forward).rate).to eq(1) } # tautology
          it { expect(subject.as(:forward).name).to eq("forward #{name}") }

          it { expect(subject.as(:reverse).rate).to eq(2) }
          it { expect(subject.as(:reverse).name).to eq("reverse #{name}") }
        end

        describe 'dimer formation' do
          it_behaves_like 'forward and reverse' do
            subject { dimer_formation }
          end

          it_behaves_like 'forward and reverse' do
            subject { dimer_formation.reverse }
          end
        end

        describe 'initialy inversed dimer formation' do
          it_behaves_like 'forward and reverse' do
            subject do
              Reaction.new(:reverse, 'dimer formation',
                df_products, df_source, df_atom_map.reverse)
            end
          end
        end
      end

      describe '#duplicate' do
        subject { dimer_formation.duplicate('tail') }

        it_behaves_like 'check duplicate property'
        it { expect(subject).to be_a(described_class) }
      end

      describe '#lateral_duplicate' do
        subject { dimer_formation.lateral_duplicate('tail', [on_end]) }

        it_behaves_like 'check duplicate property'
        it { expect(subject).to be_a(LateralReaction) }
      end

      describe '#reverse' do
        subject { methyl_desorption.reverse }
        it { should be_a(described_class) }

        it { expect(subject.source.size).to eq(2) }
        it { expect(subject.source).to include(methyl, abridge_dup) }

        it { expect(subject.products).to eq([methyl_on_bridge]) }
      end

      describe '#gases_num' do
        it { expect(methyl_desorption.gases_num).to eq(0) }
        it { expect(methyl_desorption.reverse.gases_num).to eq(1) }

        it { expect(hydrogen_migration.gases_num).to eq(0) }
        it { expect(hydrogen_migration.reverse.gases_num).to eq(0) }
      end

      describe '#swap_source' do
        let(:bridge_dup) { activated_bridge.dup }
        before(:each) do
          dimer_formation.swap_source(activated_bridge, bridge_dup)
        end

        shared_examples_for 'check specs existence' do
          it { should include(bridge_dup) }
          it { should_not include(activated_bridge) }
        end

        it_behaves_like 'check specs existence' do
          subject { dimer_formation.positions.map(&:first).map(&:first) }
        end

        it_behaves_like 'check specs existence' do
          subject { dimer_formation.positions.map { |p| p[1] }.map(&:first) }
        end

        it_behaves_like 'check specs existence' do
          subject { df_atom_map.changes.map(&:first).map(&:first) }
        end
      end

      describe 'exnchange atoms' do
        shared_examples_for 'check mapping and positions changes' do
          shared_examples_for 'check atoms existence' do
            it { should include(new_atom) }
            it { should_not include(old_atom) }
          end

          it_behaves_like 'check atoms existence' do
            subject { reaction.positions.map(&:first).map(&:last) }
          end

          it_behaves_like 'check atoms existence' do
            subject { reaction.positions.map { |p| p[1] }.map(&:last) }
          end

          it_behaves_like 'check atoms existence' do
            let(:atoms) { mapping.full.map(&:last) }
            subject { atoms.first.map(&:first) + atoms.last.map(&:first) }
          end
        end

        describe '#apply_relevants' do
          shared_examples_for 'check incoherent only one' do
            let(:old_atom) { spec.atom(target_kn) }
            let(:new_atom) { spec.atom(target_kn) }

            before(:each) do
              old_atom # initialize memoized value
              spec.incoherent!(target_kn)
              methyl_incorporation.apply_relevants(spec, old_atom, new_atom)
            end

            shared_examples_for 'for direction' do
              it { expect(direction.atom(inc_kn).incoherent?).to be_true }
              it { expect(direction.atom(not_inc_kn).incoherent?).to be_false }
            end

            it_behaves_like 'for direction' do
              let(:direction) { forward }
            end

            it_behaves_like 'for direction' do
              let(:direction) { reverse }
            end
          end

          describe 'for source' do
            let(:spec) { activated_methyl_on_extended_bridge }

            shared_examples_for 'check product' do
              it_behaves_like 'check incoherent only one' do
                let(:forward) { methyl_incorporation.products.first }
                let(:reverse) { methyl_incorporation.reverse.source.first }
              end
            end

            describe 'bridge atom' do
              it_behaves_like 'check product' do
                let(:target_kn) { :cb }
                let(:inc_kn) { :cl }
                let(:not_inc_kn) { :cr }
              end
            end

            describe 'caugth on methyl atom' do
              it_behaves_like 'check product' do
                let(:target_kn) { :cm }
                let(:inc_kn) { :cr }
                let(:not_inc_kn) { :cl }
              end
            end
          end

          describe 'for product' do
            let(:spec) { extended_dimer }

            shared_examples_for 'check source' do
              it_behaves_like 'check incoherent only one' do
                let(:forward) { methyl_incorporation.source.first }
                let(:reverse) { methyl_incorporation.reverse.products.first }
              end
            end

            it_behaves_like 'check source' do
              let(:target_kn) { :cr }
              let(:inc_kn) { :cb }
              let(:not_inc_kn) { :cm }
            end
          end
        end
      end

      describe '#position_between' do
        before { hydrogen_migration.position_between(
            [methyl_on_dimer, methyl_on_dimer.atom(:cr)],
            [activated_dimer, activated_dimer.atom(:cr)],
            position_100_front
          ) }

        describe 'opposite relation stored too' do
          it { expect(hydrogen_migration.positions).to match_array([
              [
                [methyl_on_dimer, methyl_on_dimer.atom(:cr)],
                [activated_dimer, activated_dimer.atom(:cr)],
                position_100_front
              ],
              [
                [activated_dimer, activated_dimer.atom(:cr)],
                [methyl_on_dimer, methyl_on_dimer.atom(:cr)],
                position_100_front
              ],
            ]) }
        end

        describe 'apply to reverse' do
          subject { hydrogen_migration.reverse }

          it { expect(subject.positions).to match_array([
              [
                [
                  activated_methyl_on_dimer,
                  activated_methyl_on_dimer.atom(:cr)
                ],
                [dimer, dimer.atom(:cr)],
                position_100_front
              ],
              [
                [dimer, dimer.atom(:cr)],
                [
                  activated_methyl_on_dimer,
                  activated_methyl_on_dimer.atom(:cr)
                ],
                position_100_front
              ],
            ]) }
        end
      end

      describe '#positions' do
        describe 'empty' do
          it { expect(methyl_activation.positions).to be_empty }
          it { expect(methyl_desorption.positions).to be_empty }
          it { expect(hydrogen_migration.positions).to be_empty }
        end

        describe 'dimer formation' do
          it { expect(dimer_formation.positions).to match_array([
              [
                [activated_bridge, activated_bridge.atom(:ct)],
                [
                  activated_incoherent_bridge,
                  activated_incoherent_bridge.atom(:ct)
                ],
                position_100_front
              ],
              [
                [
                  activated_incoherent_bridge,
                  activated_incoherent_bridge.atom(:ct)
                ],
                [activated_bridge, activated_bridge.atom(:ct)],
                position_100_front
              ],
            ]) }
        end
      end

      describe '#used_keynames_of' do
        it { expect(dimer_formation.used_keynames_of(activated_bridge)).to eq([:ct]) }
        it { expect(dimer_formation.used_keynames_of(activated_incoherent_bridge)).
          to eq([:ct]) }
      end

      let(:reaction) { dimer_formation.duplicate('dup') }
      let(:lateral) { dimer_formation.lateral_duplicate('tail', [on_end]) }

      describe '#same?' do
        def make_same(type)
          source = [methyl_on_dimer.dup, activated_dimer.dup]
          products = [activated_methyl_on_dimer.dup, dimer.dup]
          names_to_specs = {
            source: [[:f, source.first], [:s, source.last]],
            products: [[:f, products.first], [:s, products.last]]
          }
          atom_map = Mcs::AtomMapper.map(source, products, names_to_specs)
          Reaction.new(type, 'duplicate', source, products, atom_map)
        end

        let(:same) { make_same(:forward) }
        it { expect(hydrogen_migration.same?(same)).to be_true }
        it { expect(same.same?(hydrogen_migration)).to be_true }

        it { expect(methyl_activation.same?(methyl_deactivation)).to be_false }
        it { expect(methyl_desorption.same?(hydrogen_migration)).to be_false }

        describe 'different types' do
          let(:reverse) { make_same(:reverse) }
          it { expect(hydrogen_migration.same?(same)).to be_true }
          it { expect(same.same?(hydrogen_migration)).to be_true }
        end

        describe 'positions are different' do
          before(:each) do
            hydrogen_migration.position_between(
              [methyl_on_dimer, methyl_on_dimer.atom(:cr)],
              [activated_dimer, activated_dimer.atom(:cr)],
              position_100_front
            )
          end

          it { expect(hydrogen_migration.same?(same)).to be_false }
          it { expect(same.same?(hydrogen_migration)).to be_false }
        end

        describe 'lateral reaction' do
          it { expect(reaction.same?(lateral)).to be_true }
        end
      end

      describe '#complex_source_spec_and_atom' do
        it { expect(methyl_activation.complex_source_spec_and_atom).
          to match_array([ma_source.first, ma_source.first.atom(:cm)]) }

        it { expect(methyl_deactivation.complex_source_spec_and_atom).
          to match_array([dm_source.first, dm_source.first.atom(:cm)]) }
      end

      describe '#complex_source_covered_by?' do
        it { expect(methyl_activation.complex_source_covered_by?(adsorbed_h)).
          to be_true }
        it { expect(methyl_activation.complex_source_covered_by?(active_bond)).
          to be_false }

        it { expect(methyl_deactivation.complex_source_covered_by?(active_bond)).
          to be_true }
        it { expect(methyl_deactivation.complex_source_covered_by?(adsorbed_h)).
          to be_true }
      end

      describe '#organize_dependencies! and #more_complex' do
        before(:each) do
          lateral_reactions = [lateral]
          reaction.organize_dependencies!(lateral_reactions)
          methyl_desorption.organize_dependencies!(lateral_reactions)
        end
        it { expect(reaction.more_complex).to eq([lateral]) }
        it { expect(methyl_desorption.more_complex).to be_empty }
      end

      describe '#size' do
        it { expect(methyl_activation.size.round(2)).to eq(4) }
        it { expect(dimer_formation.size.round(2)).to eq(6.81) }
      end

      it_behaves_like 'visitable' do
        subject { methyl_desorption }
      end

      describe '#changes' do
        it { expect(dimer_formation.changes).to match_array([
            [
              [activated_bridge, activated_bridge.atom(:ct)],
              [dimer_dup_ff, dimer_dup_ff.atom(:cr)],
            ],
            [
              [
                activated_incoherent_bridge,
                activated_incoherent_bridge.atom(:ct)
              ],
              [dimer_dup_ff, dimer_dup_ff.atom(:cl)],
            ]
          ]) }
      end

      describe '#changes_size' do
        it { expect(dimer_formation.changes_size).to eq(2) }
        it { expect(hydrogen_migration.changes_size).to eq(2) }
        it { expect(methyl_incorporation.changes_size).to eq(4) }
      end
    end

  end
end
