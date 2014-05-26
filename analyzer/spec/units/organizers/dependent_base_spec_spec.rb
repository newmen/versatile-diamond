require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe DependentBaseSpec do
      def wrap(spec)
        described_class.new(spec)
      end

      describe '#parents' do
        it { expect(wrap(bridge_base).parents).to be_empty }
      end

      describe 'parents <-> children' do
        let(:parent) { wrap(bridge_base) }
        let(:child) { wrap(methyl_on_bridge_base) }

        it_behaves_like :multi_parents
        it_behaves_like :multi_children

        describe '#remove_child' do
          before do
            child.store_parent(parent)
            parent.remove_child(child)
          end

          it { expect(parent.children).to be_empty }
          it { expect(child.parents).to eq([parent]) }
        end
      end

      it_behaves_like :minuend do
        subject { wrap(bridge_base) }
      end

      describe '#rest' do
        it { expect(wrap(bridge_base).rest).to be_nil }
      end

      describe '#store_rest' do
        subject { wrap(methyl_on_bridge_base) }
        let(:rest) { subject - wrap(bridge_base) }
        before { subject.store_rest(rest) }
        it { expect(subject.rest).to eq(rest) }
      end

      describe '#size' do
        subject { wrap(bridge_base) }
        it { expect(subject.size).to eq(subject.spec.size) }
      end

      describe '#same?' do
        describe 'bridge_base' do
          let(:same_bridge) { wrap(bridge_base_dup) }
          subject { wrap(bridge_base) }

          it { expect(subject.same?(same_bridge)).to be_true }
          it { expect(same_bridge.same?(subject)).to be_true }

          it { expect(subject.same?(wrap(dimer_base))).to be_false }
        end

        describe 'methyl_on_bridge_base' do
          let(:other) { wrap(high_bridge_base) }
          subject { wrap(methyl_on_bridge_base) }

          it { expect(subject.same?(other)).to be_false }
          it { expect(other.same?(subject)).to be_false }
        end
      end

      describe '# - ' do
        subject { wrap(methyl_on_right_bridge_base) - wrap(bridge_base) }

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
        let(:spec) { bridge_base }
        let(:atom) { spec.atom(:cr) }
        let(:rls) do
          [bond_110_front, bond_110_cross, bond_110_cross, position_100_front]
        end
      end

      describe '#organize_dependencies!' do
        let(:specs) do
          [
            bridge_base,
            dimer_base,
            high_bridge_base,
            methyl_on_bridge_base,
            methyl_on_dimer_base,
            extended_bridge_base,
            extended_dimer_base,
            methyl_on_extended_bridge_base,
          ]
        end

        let(:wrapped_specs) { specs.map { |spec| wrap(spec) } }
        let(:cache) { Hash[wrapped_specs.map(&:name).zip(wrapped_specs)] }
        let(:table) { BaseSpeciesTable.new(wrapped_specs) }

        describe 'bridge' do
          subject { cache[:bridge] }
          before { subject.organize_dependencies!(table) }

          describe '#rest' do
            it { expect(subject.rest).to be_nil }
          end

          describe '#parents' do
            it { expect(subject.parents).to be_empty }
          end
        end

        describe 'methyl_on_bridge' do
          subject { cache[:methyl_on_bridge] }
          before { subject.organize_dependencies!(table) }

          describe '#rest' do
            it { expect(subject.rest.atoms_num).to eq(2) }
          end

          describe '#parents' do
            it { expect(subject.parents).to eq([cache[:bridge]]) }
          end
        end
      end

      describe '#specific?' do
        it { expect(wrap(methyl_on_dimer_base).specific?).to be_false }
      end

      describe '#unused?' do
        describe 'default behavior' do
          it { expect(wrap(bridge_base)).to be_true }
        end

        describe 'with children' do
          subject { wrap(methyl_on_bridge_base) }
          let(:parent) { wrap(bridge_base) }
          let(:child) { wrap(methyl_on_dimer_base) }

          before do
            subject.store_parent(parent)
            child.store_parent(subject)
          end

          it { expect(subject.unused?).to be_false }
        end

        describe 'with reactions' do
          let(:parent) { wrap(bridge_base) }
          subject { wrap(methyl_on_bridge_base) }

          before do
            subject.store_reaction(methyl_activation)
            subject.store_parent(parent)
          end

          it { expect(subject.unused?).to be_false }
        end

        describe 'with theres' do
          let(:parent) { wrap(bridge_base) }
          subject { wrap(methyl_on_bridge_base) }

          before do
            subject.store_there(there_methyl)
            subject.store_parent(parent)
          end

          it { expect(subject.unused?).to be_false }
        end
      end

      describe '#excess?' do
        let(:wrapped_bridge) { wrap(bridge_base) }

        describe 'default behavior' do
          it { expect(wrapped_bridge.excess?).to be_false }
        end

        describe 'source behavior' do
          let(:wrapped_activated_bridge) do
            DependentSpecificSpec.new(activated_bridge)
          end

          before { wrapped_bridge.store_child(wrapped_activated_bridge) }
          it { expect(wrapped_bridge.excess?).to be_false }
        end

        describe 'intermediated behavior' do
          let(:wrapped_methyl_on_bridge) { described_class.new(methyl_on_bridge_base) }
          let(:wrapped_methyl_on_dimer) { described_class.new(methyl_on_dimer_base) }

          before do
            wrapped_methyl_on_bridge.store_parent(wrapped_bridge)
            wrapped_methyl_on_bridge.store_child(wrapped_methyl_on_dimer)
          end

          it { expect(wrapped_methyl_on_bridge.excess?).to be_false }
        end

        describe 'border behavior' do
          let(:wrapped_dimer) { wrap(dimer_base) }
          let(:wrapped_activated_dimer) do
            DependentSpecificSpec.new(activated_dimer)
          end

          before do
            wrapped_dimer.store_parent(wrapped_bridge)
            wrapped_dimer.store_parent(wrapped_bridge)
            wrapped_dimer.store_child(wrapped_activated_dimer)
          end

          it { expect(wrapped_dimer.excess?).to be_false }
        end

        describe 'excess behavior' do
          let(:wrapped_methyl_on_bridge) { wrap(methyl_on_bridge_base) }
          let(:wrapped_activated_methyl_on_dimer) do
            DependentSpecificSpec.new(activated_methyl_on_dimer)
          end

          before do
            wrapped_methyl_on_bridge.store_parent(wrapped_bridge)
            wrapped_methyl_on_bridge.store_child(wrapped_activated_methyl_on_dimer)
          end

          it { expect(wrapped_methyl_on_bridge.excess?).to be_true }
        end
      end

      describe '#exclude' do
        let(:left) { wrap(bridge_base) }
        let(:middle) { wrap(methyl_on_bridge_base) }
        let(:right) { DependentSpecificSpec.new(activated_methyl_on_bridge) }

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
