require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe DependentBaseSpec, type: :organizer do
      it_behaves_like :minuend do
        subject { dept_bridge_base }
        let(:bigger) { dept_methyl_on_bridge_base }

        [:ct, :cr, :cl].each do |kn|
          let(kn) { bridge_base.atom(kn) }
        end

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

      it_behaves_like :count_atoms_and_relations_and_parents do
        subject { dept_methyl_on_right_bridge_base - dept_bridge_base }
        let(:atoms_num) { 2 }
        let(:relations_num) { 6 }
        let(:parents_num) { 1 }
      end

      it_behaves_like :wrapped_spec do
        subject { dept_bridge_base }
        let(:child) { dept_methyl_on_bridge_base }
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
          expect(dept_bridge_base).to be_truthy
        end

        it_behaves_like :organize_dependencies do
          subject { dept_methyl_on_bridge_base }
          let(:others) { [dept_bridge_base, dept_methyl_on_dimer_base] }
          it { expect(subject.unused?).to be_falsey }
        end

        it_behaves_like :organize_dependencies do
          subject { dept_methyl_on_bridge_base }
          let(:others) { [dept_bridge_base] }
          before { subject.store_reaction(methyl_activation) }
          it { expect(subject.unused?).to be_falsey }
        end

        it_behaves_like :organize_dependencies do
          subject { dept_methyl_on_bridge_base }
          let(:others) { [dept_bridge_base] }
          before { subject.store_there(there_methyl) }
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
