require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe SpecResidual, type: :organizer do
      let(:methyl_on_bridge_part) { dept_methyl_on_bridge_base - dept_bridge_base }
      let(:high_bridge_part) { dept_high_bridge_base - dept_bridge_base }
      let(:big_dimer_part) { dept_dimer_base - dept_bridge_base }
      let(:small_dimer_part) { big_dimer_part - dept_bridge_base }

      it_behaves_like :minuend do
        subject do
          dept_methyl_on_dimer_base - dept_methyl_on_bridge_base - dept_bridge_base
        end
        let(:bigger) { dept_methyl_on_dimer_base - dept_dimer_base }

        let_atoms_of(:methyl_on_dimer_base, [:cm, :cr, :crb, :_cr0, :cl, :clb, :_cr1])

        let(:atom) { cr }
        let(:atom_relations) do
          [free_bond, bond_100_front, bond_110_cross, bond_110_cross]
        end

        let(:clean_links) do
          {
            cr => [
              [cm, free_bond],
              [cl, bond_100_front],
              [crb, bond_110_cross],
              [_cr0, bond_110_cross]
            ],
            cl => [
              [cr, bond_100_front],
              [clb, bond_110_cross],
              [_cr1, bond_110_cross]
            ],
          }
        end
      end

      describe '#self.empty' do
        subject { described_class.empty(dept_bridge_base) }
        it { expect(subject.links).to eq(dept_bridge_base.links) }
        it { expect(subject.parents).to be_empty }
      end

      describe '#clone_with_replace_by' do
        subject { small_dimer_part }
        let(:mirror) { Mcs::SpeciesComparator.make_mirror(dimer_base, dimer_base_dup) }
        let(:clone) { subject.clone_with_replace_by(dept_dimer_base_dup, mirror) }

        it { expect(clone).to be_a(described_class) }
        it { expect(clone).not_to eq(subject) }
        it { expect(subject).not_to eq(clone) }

        describe 'different atoms' do
          let(:atoms) do
            clone.links.flat_map { |atom, rels| [atom] + rels.map(&:first) }
          end

          it { expect(atoms.all? { |a| dimer_base_dup.keyname(a) }).to be_truthy }
        end
      end

      describe '#same?' do
        describe 'methyl_on_bridge_dup' do
          let(:another_mob_part) { dept_methyl_on_bridge_base_dup - dept_bridge_base }

          it { expect(methyl_on_bridge_part.same?(another_mob_part)).to be_truthy }

          it { expect(methyl_on_bridge_part.same?(big_dimer_part)).to be_falsey }
          it { expect(methyl_on_bridge_part.same?(high_bridge_part)).to be_falsey }
        end

        describe 'rests of (dimer - bridge), (methyl_on_dimer - methyl_on_bridge)' do
          let(:big_mod_part) { dept_methyl_on_dimer_base - dept_methyl_on_bridge_base }

          it { expect(big_dimer_part.same?(big_mod_part)).to be_falsey }
          it { expect(big_mod_part.same?(big_dimer_part)).to be_falsey }
        end

        describe 'vinyl_of_dimer && methyl_on_dimer' do
          let(:mod_part) do
            dept_methyl_on_dimer_base - dept_methyl_on_bridge_base - dept_bridge_base
          end
          let(:vod_part) do
            dept_vinyl_on_dimer_base - dept_vinyl_on_bridge_base - dept_bridge_base
          end

          it { expect(mod_part.same?(vod_part)).to be_falsey }
          it { expect(vod_part.same?(mod_part)).to be_falsey }
        end
      end

      describe '# - ' do
        it_behaves_like :count_atoms_and_relations_and_parents do
          subject { big_dimer_part }
          let(:atoms_num) { 4 }
          let(:relations_num) { 14 }
          let(:parents_num) { 1 }
        end

        it_behaves_like :count_atoms_and_relations_and_parents do
          subject { small_dimer_part }
          let(:atoms_num) { 2 }
          let(:relations_num) { 6 }
          let(:parents_num) { 2 }
        end

        it_behaves_like :count_atoms_and_relations_and_parents do
          let(:small_spec1) { dept_methyl_on_bridge_base }
          let(:small_spec2) { dept_bridge_base_dup }
          let(:big_spec) { dept_methyl_on_dimer_base }
          subject { big_spec - small_spec1 - small_spec2 }

          let(:atoms_num) { 2 }
          let(:relations_num) { 7 }
          let(:parents_num) { 2 }
        end

        it_behaves_like :count_atoms_and_relations_and_parents do
          let(:eb) { dept_extended_bridge_base }
          subject { eb - dept_bridge_base - dept_bridge_base - dept_bridge_base }

          let(:atoms_num) { 2 }
          let(:relations_num) { 8 }
          let(:parents_num) { 3 }
        end

        it_behaves_like :count_atoms_and_relations_and_parents do
          let(:tbs) { dept_three_bridges_base }
          subject { tbs - dept_bridge_base - dept_bridge_base - dept_bridge_base }

          let(:atoms_num) { 2 }
          let(:relations_num) { 10 }
          let(:parents_num) { 3 }
        end

        describe 'cross_bridge_on_bridges' do
          let(:cbobs) { dept_cross_bridge_on_bridges_base }
          let(:cbobs_part) { cbobs - dept_methyl_on_bridge_base }

          it_behaves_like :count_atoms_and_relations_and_parents do
            subject { cbobs_part }
            let(:atoms_num) { 5 }
            let(:relations_num) { 18 }
            let(:parents_num) { 1 }
          end

          it_behaves_like :count_atoms_and_relations_and_parents do
            subject { cbobs_part - dept_methyl_on_bridge_base }
            let(:atoms_num) { 3 }
            let(:relations_num) { 10 }
            let(:parents_num) { 2 }
          end
        end
      end
    end

  end
end
