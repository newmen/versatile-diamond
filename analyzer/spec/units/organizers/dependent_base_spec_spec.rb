require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe DependentBaseSpec, type: :organizer do
      describe '#parents' do
        it { expect(dept_bridge_base.parents).to be_empty }
      end

      describe 'parents <-> children' do
        let(:parent) { dept_bridge_base }
        let(:child) { dept_methyl_on_bridge_base }

        it_behaves_like :multi_parents
        it_behaves_like :multi_children
        it_behaves_like :wrapped_spec

        describe '#remove_child' do
          before do
            child.store_parent(parent)
            parent.remove_child(child)
          end

          it { expect(parent.children).to be_empty }
          it { expect(child.parents).to eq([parent]) }
        end
      end

      describe 'residual behavior' do
        subject { dept_methyl_on_bridge_base }

        it_behaves_like :minuend
        it_behaves_like :residual_container do
          let(:subtrahend) { dept_bridge_base }
        end
      end

      describe '#size' do
        subject { dept_bridge_base }
        it { expect(subject.size).to eq(subject.spec.size) }
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

      describe '# - ' do
        subject { dept_methyl_on_right_bridge_base - dept_bridge_base }

        it_behaves_like :count_atoms_and_references do
          let(:atoms_num) { 2 }
          let(:relations_num) { 6 }
        end

        describe 'detailed' do
          let(:atoms) { subject.links.keys }

          let(:cm) { atoms.first }
          it { expect(subject.relations_of(cm).size).to eq(1) }

          let(:cb) { atoms.last }
          let(:rls) do
            [
              free_bond,
              bond_110_front,
              bond_110_cross,
              bond_110_cross,
              position_100_front
            ]
          end

          it { expect(subject.relations_of(cb)).to match_array(rls) }
        end
      end

      it_behaves_like :relations_of do
        subject { dept_bridge_base }
        let(:atom) { bridge_base.atom(:cr) }
        let(:rls) do
          [bond_110_front, bond_110_cross, bond_110_cross, position_100_front]
        end
      end

      describe '#organize_dependencies!' do
        let(:table) { BaseSpeciesTable.new(dependent_base_species) }
        let(:dependent_base_species) do
          [
            dept_bridge_base,
            dept_dimer_base,
            dept_high_bridge_base,
            dept_methyl_on_bridge_base,
            dept_methyl_on_dimer_base,
            dept_extended_bridge_base,
            dept_extended_dimer_base,
            dept_methyl_on_extended_bridge_base,
          ]
        end

        describe 'bridge' do
          subject { dept_bridge_base }
          before { subject.organize_dependencies!(table) }

          describe '#rest' do
            it { expect(subject.rest).to be_nil }
          end

          describe '#parents' do
            it { expect(subject.parents).to be_empty }
          end
        end

        describe 'methyl_on_bridge' do
          subject { dept_methyl_on_bridge_base }
          before { subject.organize_dependencies!(table) }

          describe '#rest' do
            it { expect(subject.rest.atoms_num).to eq(2) }
          end

          describe '#parents' do
            it { expect(subject.parents).to eq([dept_bridge_base]) }
          end
        end
      end

      describe '#specific?' do
        it { expect(dept_methyl_on_dimer_base.specific?).to be_falsey }
      end

      describe '#unused?' do
        describe 'default behavior' do
          it { expect(dept_bridge_base).to be_truthy }
        end

        describe 'with children' do
          subject { dept_methyl_on_bridge_base }
          let(:parent) { dept_bridge_base }
          let(:child) { dept_methyl_on_dimer_base }

          before do
            subject.store_parent(parent)
            child.store_parent(subject)
          end

          it { expect(subject.unused?).to be_falsey }
        end

        describe 'with reactions' do
          let(:parent) { dept_bridge_base }
          subject { dept_methyl_on_bridge_base }

          before do
            subject.store_reaction(methyl_activation)
            subject.store_parent(parent)
          end

          it { expect(subject.unused?).to be_falsey }
        end

        describe 'with theres' do
          let(:parent) { dept_bridge_base }
          subject { dept_methyl_on_bridge_base }

          before do
            subject.store_there(there_methyl)
            subject.store_parent(parent)
          end

          it { expect(subject.unused?).to be_falsey }
        end
      end

      describe '#excess?' do
        describe 'default behavior' do
          it { expect(dept_bridge_base.excess?).to be_falsey }
        end

        describe 'source behavior' do
          before { dept_bridge_base.store_child(dept_activated_bridge) }
          it { expect(dept_bridge_base.excess?).to be_falsey }
        end

        describe 'intermediated behavior' do
          before do
            dept_methyl_on_bridge_base.store_parent(dept_bridge_base)
            dept_methyl_on_bridge_base.store_child(dept_methyl_on_dimer_base)
          end

          it { expect(dept_methyl_on_bridge_base.excess?).to be_falsey }
        end

        describe 'border behavior' do
          before do
            dept_dimer_base.store_parent(dept_bridge_base)
            dept_dimer_base.store_parent(dept_bridge_base)
            dept_dimer_base.store_child(dept_activated_dimer)
          end

          it { expect(dept_dimer_base.excess?).to be_falsey }
        end

        describe 'excess behavior' do
          before do
            dept_methyl_on_bridge_base.store_parent(dept_bridge_base)
            dept_methyl_on_bridge_base.store_child(dept_activated_methyl_on_dimer)
          end

          it { expect(dept_methyl_on_bridge_base.excess?).to be_truthy }
        end
      end

      describe '#exclude' do
        let(:left) { dept_bridge_base }
        let(:middle) { dept_methyl_on_bridge_base }
        let(:right) { dept_activated_methyl_on_bridge }

        before do
          middle.store_rest(middle - left)
          middle.store_parent(left)
          right.store_parent(middle)
          middle.exclude
        end

        it { expect(left.children).to eq([right]) }
        it { expect(right.parent).to eq(left) }
        it { expect(left.rest).to be_nil }

        describe 'rest of right' do
          let(:links) { right.rest.links }
          let(:relations) do
            [free_bond, free_bond, :active, bond_110_cross, bond_110_cross]
          end

          it { expect(links.keys.map(&:actives)).to match_array([1, 0]) }
          it { expect(links.values.reduce(:+).map(&:last)).to match_array(relations) }
        end
      end
    end

  end
end
