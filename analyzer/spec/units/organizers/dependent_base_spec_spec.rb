require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe DependentBaseSpec, type: :organizer do
      it_behaves_like :minuend do
        subject { dept_bridge_base }
        let(:bigger) { dept_methyl_on_bridge_base }

        let_atoms_of(:bridge_base, [:ct, :cr, :cl])

        let(:atom) { cr }
        let(:atom_relations) do
          [bond_110_front, position_100_front, bond_110_cross, bond_110_cross]
        end

        let(:clean_links) do
          {
            ct => [[cr, bond_110_cross], [cl, bond_110_cross]],
            cr => [[ct, bond_110_front]],
            cl => [[ct, bond_110_front]]
          }
        end
      end

      it_behaves_like :check_clean_links do
        subject { dept_intermed_migr_down_full_base }

        let_atoms_of(:intermed_migr_down_full_base, [
          :cm, :cb, :cbl, :cbr, :cdl, :cdr, :crb, :clb, :_cr0, :_cr1
        ])

        let(:clean_links) do
          {
            cm => [[cb, free_bond], [cdr, free_bond]],
            cb => [[cbr, bond_110_cross], [cbl, bond_110_cross], [cm, free_bond]],
            cbr => [[cb, bond_110_front], [cdr, position_100_cross]],
            cbl => [[cb, bond_110_front], [cdl, position_100_cross]],
            crb => [[cdr, bond_110_front]],
            _cr0 => [[cdr, bond_110_front]],
            clb => [[cdl, bond_110_front]],
            _cr1 => [[cdl, bond_110_front]],
            cdl => [
              [cdr, bond_100_front],
              [clb, bond_110_cross],
              [_cr1, bond_110_cross],
              [cbl, position_100_cross]
            ],
            cdr => [
              [cdl, bond_100_front],
              [crb, bond_110_cross],
              [_cr0, bond_110_cross],
              [cbr, position_100_cross],
              [cm, free_bond]
            ]
          }
        end
      end

      it_behaves_like :count_atoms_and_relations_and_parents do
        subject { dept_methyl_on_right_bridge_base - dept_bridge_base }
        let(:atoms_num) { 2 }
        let(:relations_num) { 6 }
        let(:parents_num) { 1 }
      end

      it_behaves_like :wrapped_spec do
        subject { dept_bridge_base }
        let(:reaction) { dept_methyl_activation }
        let(:child) { described_class.new(ma_source.first) }
      end

      it_behaves_like :parents_with_twins do
        subject { dept_three_bridges_base }
        let(:others) { [dept_bridge_base] }
        let(:atom) { three_bridges_base.atom(:ct) }
        let(:parents_with_twins) do
          [
            [dept_bridge_base, bridge_base.atom(:ct)],
            [dept_bridge_base, bridge_base.atom(:cr)]
          ]
        end
      end

      describe '#specific_atoms' do
        it { expect(dept_bridge_base.specific_atoms).to be_empty }
      end

      describe '#same?' do
        describe 'bridge_base' do
          it { expect(dept_bridge_base.same?(dept_bridge_base_dup)).to be_truthy }
          it { expect(dept_bridge_base_dup.same?(dept_bridge_base)).to be_truthy }

          it { expect(dept_bridge_base.same?(dept_dimer_base)).to be_falsey }
        end

        describe 'methyl_on_bridge_base' do
          let(:other) { dept_high_bridge_base }
          subject { dept_methyl_on_bridge_base }

          it { expect(subject.same?(other)).to be_falsey }
          it { expect(other.same?(subject)).to be_falsey }
        end
      end

      describe '#specific?' do
        it { expect(dept_methyl_on_dimer_base.specific?).to be_falsey }
      end

      describe '#unused?' do
        it 'default behavior' do
          expect(dept_bridge_base.unused?).to be_falsey
        end

        it_behaves_like :organize_dependencies do
          subject { dept_methyl_on_bridge_base }
          let(:others) { [dept_bridge_base, dept_methyl_on_dimer_base] }
          it { expect(subject.unused?).to be_falsey }
        end

        it_behaves_like :organize_dependencies do
          subject { described_class.new(ma_source.first) }
          let(:others) { [dept_bridge_base] }
          before { subject.store_reaction(dept_methyl_activation) }
          it { expect(subject.unused?).to be_falsey }
        end

        it_behaves_like :organize_dependencies do
          subject { described_class.new(on_end.env_specs.first) }
          let(:others) { [dept_bridge_base] }
          before { subject.store_there(dept_on_end) }
          it { expect(subject.unused?).to be_falsey }
        end
      end

      describe '#excess?' do
        it 'default behavior' do
          expect(dept_bridge_base.excess?).to be_falsey
        end

        it_behaves_like :organize_dependencies do
          subject { dept_bridge_base }
          let(:others) { [dept_activated_bridge] }
          it { expect(subject.excess?).to be_falsey }
        end

        it_behaves_like :organize_dependencies do
          subject { dept_dimer_base }
          let(:others) { [dept_bridge_base, dept_activated_dimer] }
          it { expect(subject.excess?).to be_falsey }
        end

        it_behaves_like :organize_dependencies do
          subject { dept_methyl_on_bridge_base }
          let(:others) { [dept_bridge_base, dept_activated_methyl_on_bridge] }
          it { expect(subject.excess?).to be_truthy }
        end
      end

      describe '#exclude' do
        it_behaves_like :organize_dependencies do
          subject { dept_methyl_on_bridge_base }
          let(:others) { [dept_bridge_base, dept_activated_methyl_on_bridge] }
          let(:parent) { dept_bridge_base }
          let(:child) { dept_activated_methyl_on_bridge }

          before { subject.exclude }

          it { expect(parent.children).to eq([child]) }
          it { expect(child.parents.map(&:original)).to eq([parent]) }
        end
      end
    end

  end
end
