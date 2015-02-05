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

      shared_examples_for :check_duplicate_property do
        it { expect(subject.name).to match(/tail$/) }
        it { expect(subject.reverse.name).to match(/tail$/) }

        it { expect(subject.source).not_to eq(df_source) }
        it { expect(subject.source.first).not_to eq(df_source.first) }
        it { expect(subject.products).not_to eq(df_products) }
        it { expect(subject.products.first).not_to eq(df_products.first) }
        it { expect(subject.products.last).not_to eq(df_products.last) }

        shared_examples_for :child_changes_too do
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

        it_behaves_like :child_changes_too do
          let(:reaction) { dimer_formation }
          let(:child) { subject }
        end

        it_behaves_like :child_changes_too do
          let(:reaction) { dimer_formation.reverse }
          let(:child) { subject.reverse }
        end
      end

      describe '#as' do
        shared_examples_for :forward_and_reverse do
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
          it_behaves_like :forward_and_reverse do
            subject { dimer_formation }
          end

          it_behaves_like :forward_and_reverse do
            subject { dimer_formation.reverse }
          end
        end

        describe 'initialy inversed dimer formation' do
          it_behaves_like :forward_and_reverse do
            subject do
              Reaction.new(:reverse, 'dimer formation',
                df_products, df_source, df_atom_map.reverse)
            end
          end
        end
      end

      describe '#duplicate' do
        subject { dimer_formation.duplicate('tail') }

        it_behaves_like :check_duplicate_property
        it { expect(subject).to be_a(described_class) }
      end

      describe '#lateral_duplicate' do
        subject { dimer_formation.lateral_duplicate('tail', [on_end]) }

        it_behaves_like :check_duplicate_property
        it { expect(subject).to be_a(LateralReaction) }
      end

      describe '#reverse' do
        subject { hydrogen_migration.reverse }
        it { should be_a(described_class) }

        it { expect(subject.source).to match_array(hm_products) }
        it { expect(subject.products).to match_array(hm_source) }
      end

      describe '#gases_num' do
        it { expect(methyl_adsorption.gases_num).to eq(1) }
        it { expect(methyl_desorption.gases_num).to eq(1) }

        it { expect(hydrogen_migration.gases_num).to eq(0) }
        it { expect(hydrogen_migration.reverse.gases_num).to eq(0) }
      end

      describe '#swap_source' do
        shared_examples_for :check_specs_existence do
          before { reaction.swap_source(old, fresh) }
          it { should include(fresh) }
          it { should_not include(old) }
        end

        shared_examples_for :check_mapping do
          it_behaves_like :check_specs_existence do
            subject { map.changes.map(&:first).map(&:first) }
          end
        end

        describe 'to specific spec' do
          let(:reaction) { dimer_formation }
          let(:old) { df_source.first }
          let(:fresh) { old.dup }

          it_behaves_like :check_mapping do
            let(:map) { df_atom_map }
          end

          it_behaves_like :check_specs_existence do
            subject { reaction.links.keys.map(&:first) }
          end

          it_behaves_like :check_specs_existence do
            subject do
              reaction.links.values.flat_map { |rels| rels.map(&:first) }.map(&:first)
            end
          end
        end

        describe 'to base spec' do
          it_behaves_like :check_mapping do
            let(:old) { hm_products.last }
            let(:fresh) { dimer_base }
            let(:reaction) { hydrogen_migration.reverse }
            let(:map) { reaction.instance_variable_get(:'@mapping') }
          end
        end
      end

      describe 'exnchange atoms' do
        shared_examples_for :check_mapping_and_positions_changes do
          shared_examples_for :check_atoms_existence do
            it { should include(new_atom) }
            it { should_not include(old_atom) }
          end

          it_behaves_like :check_atoms_existence do
            subject { reaction.positions.map(&:first).map(&:last) }
          end

          it_behaves_like :check_atoms_existence do
            subject { reaction.positions.map { |p| p[1] }.map(&:last) }
          end

          it_behaves_like :check_atoms_existence do
            let(:atoms) { mapping.full.map(&:last) }
            subject { atoms.first.map(&:first) + atoms.last.map(&:first) }
          end
        end

        describe '#apply_relevants' do
          shared_examples_for :check_incoherent_only_one do
            let(:old_atom) { spec.atom(target_kn) }
            let(:new_atom) { spec.atom(target_kn) }

            before(:each) do
              old_atom # initialize memoized value
              spec.incoherent!(target_kn)
              methyl_incorporation.apply_relevants(spec, old_atom, new_atom)
            end

            shared_examples_for :for_direction do
              it { expect(direction.atom(inc_kn).incoherent?).to be_truthy }
              it { expect(direction.atom(not_inc_kn).incoherent?).to be_falsey }
            end

            it_behaves_like :for_direction do
              let(:direction) { forward }
            end

            it_behaves_like :for_direction do
              let(:direction) { reverse }
            end
          end

          describe 'for source' do
            let(:spec) { mi_source.first }

            shared_examples_for :check_product do
              it_behaves_like :check_incoherent_only_one do
                let(:forward) { methyl_incorporation.products.first }
                let(:reverse) { methyl_incorporation.reverse.source.first }
              end
            end

            describe 'bridge atom' do
              it_behaves_like :check_product do
                let(:target_kn) { :cb }
                let(:inc_kn) { :cl }
                let(:not_inc_kn) { :cr }
              end
            end

            describe 'caugth on methyl atom' do
              it_behaves_like :check_product do
                let(:target_kn) { :cm }
                let(:inc_kn) { :cr }
                let(:not_inc_kn) { :cl }
              end
            end
          end

          describe 'for product' do
            let(:spec) { mi_product.first }

            shared_examples_for :check_source do
              it_behaves_like :check_incoherent_only_one do
                let(:forward) { methyl_incorporation.source.first }
                let(:reverse) { methyl_incorporation.reverse.products.first }
              end
            end

            it_behaves_like :check_source do
              let(:target_kn) { :cr }
              let(:inc_kn) { :cb }
              let(:not_inc_kn) { :cm }
            end
          end
        end
      end

      describe '#positions' do
        describe 'empty' do
          it { expect(methyl_activation.positions).to be_empty }
          it { expect(methyl_desorption.positions).to be_empty }
        end

        shared_examples_for :check_positions do
          it { expect(subject.positions).to match_array(positions) }
        end

        it_behaves_like :check_positions do
          subject { dimer_formation }
          let(:s1) { df_source.first }
          let(:s2) { df_source.last }
          let(:positions) do
            [
              [[s1, s1.atom(:ct)], [s2, s2.atom(:ct)], position_100_front],
              [[s2, s2.atom(:ct)], [s1, s1.atom(:ct)], position_100_front]
            ]
          end
        end

        it_behaves_like :check_positions do
          subject { methyl_incorporation }
          let(:s1) { mi_source.first }
          let(:s2) { mi_source.last }
          let(:positions) do
            [
              [[s1, s1.atom(:cl)], [s2, s2.atom(:cr)], position_100_cross],
              [[s1, s1.atom(:cr)], [s2, s2.atom(:cl)], position_100_cross],
              [[s2, s2.atom(:cr)], [s1, s1.atom(:cl)], position_100_cross],
              [[s2, s2.atom(:cl)], [s1, s1.atom(:cr)], position_100_cross]
            ]
          end
        end
      end

      describe '#position_between' do
        # method uses for building reaction in Concepts::Handbook
        subject { hydrogen_migration }
        let(:s1) { hm_source.first }
        let(:s2) { hm_source.last }
        let(:links) do
          {
            [s1, s1.atom(:cr)] => [[[s2, s2.atom(:cr)], position_100_front]],
            [s2, s2.atom(:cr)] => [[[s1, s1.atom(:cr)], position_100_front]]
          }
        end
        it { expect(subject.links).to match_graph(links) }
      end

      describe '#used_atoms_of' do
        describe 'methyl incorporation' do
          subject { methyl_incorporation }
          let(:spec) { mi_source.first }
          let(:atoms) { [:cm, :cb, :cr, :cl].map { |a| spec.atom(a) } }

          it { expect(subject.used_atoms_of(spec)).to match_array(atoms) }
        end

        describe 'dimer formation' do
          subject { dimer_formation }
          let(:first) { df_source.first }
          let(:second) { df_source.last }

          it { expect(subject.used_atoms_of(first)).to eq([first.atom(:ct)]) }
          it { expect(subject.used_atoms_of(second)).to eq([second.atom(:ct)]) }
        end
      end

      describe '#same?' do
        describe 'basic case' do
          it { expect(methyl_activation.same?(methyl_deactivation)).to be_falsey }
          it { expect(methyl_deactivation.same?(methyl_activation)).to be_falsey }
        end

        describe 'similar reaction' do
          let(:hm_wo_pos) do
            source = [methyl_on_dimer.dup, activated_dimer.dup]
            products = [activated_methyl_on_dimer.dup, dimer.dup]
            names_to_specs = {
              source: [[:f, source.first], [:s, source.last]],
              products: [[:f, products.first], [:s, products.last]]
            }
            atom_map = Mcs::AtomMapper.map(source, products, names_to_specs)
            described_class.new(:forward, 'duplicate', source, products, atom_map)
          end

          describe 'same positions' do
            before do
              s1, s2 = hm_wo_pos.source
              hm_wo_pos.position_between(
                [s2, s2.atom(:cr)], [s1, s1.atom(:cr)], position_100_front)
            end

            it { expect(hydrogen_migration.same?(hm_wo_pos)).to be_truthy }
            it { expect(hm_wo_pos.same?(hydrogen_migration)).to be_truthy }
          end

          describe 'positions are different' do
            before do
              s1, s2 = hm_wo_pos.source
              hm_wo_pos.position_between(
                [s2, s2.atom(:cr)], [s1, s1.atom(:cr)], position_100_cross)
            end

            it { expect(hydrogen_migration.same?(hm_wo_pos)).to be_falsey }
            it { expect(hm_wo_pos.same?(hydrogen_migration)).to be_falsey }
          end
        end

        describe 'lateral reaction' do
          subject { dimer_formation.duplicate('dup') }
          it { expect(subject.same?(end_lateral_df)).to be_falsey }
        end
      end

      describe '#complex_source_spec_and_atom' do
        it { expect(methyl_activation.complex_source_spec_and_atom).
          to match_array([ma_source.first, ma_source.first.atom(:cm)]) }

        it { expect(methyl_deactivation.complex_source_spec_and_atom).
          to match_array([dm_source.first, dm_source.first.atom(:cm)]) }
      end

      describe '#changes' do
        let(:s1) { df_source.first }
        let(:s2) { df_source.last }
        let(:p1) { df_products.first }
        let(:changes) do
          {
            [s1, s1.atom(:ct)] => [p1, p1.atom(:cr)],
            [s2, s2.atom(:ct)] => [p1, p1.atom(:cl)]
          }
        end
        it { expect(dimer_formation.changes).to match_array(changes) }
      end

      describe '#changes_num' do
        it { expect(dimer_formation.changes_num).to eq(2) }
        it { expect(hydrogen_migration.changes_num).to eq(2) }
        it { expect(methyl_incorporation.changes_num).to eq(4) }
      end
    end

  end
end
