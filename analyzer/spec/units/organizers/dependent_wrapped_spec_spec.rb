require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe DependentWrappedSpec, type: :organizer do
      subject { described_class.new(bridge_base) }

      describe '#initialize' do
        describe '#straighten_graph' do
          it { expect(subject.atoms_num).to eq(3) }
          it { expect(subject.relations_num).to eq(10) }
        end
      end

      describe '#gas?' do
        it { expect(subject.gas?).to eq(subject.spec.gas?) }
      end

      describe '#external_bonds' do
        it { expect(subject.external_bonds).to eq(subject.spec.external_bonds) }
      end

      describe '#anchors' do
        it { expect(subject.anchors).to match_array(bridge_base.links.keys) }
      end

      describe '#sorted_parents' do
        subject { dept_methyl_on_dimer_base }
        let(:sorted_parents) { [dept_methyl_on_bridge_base, dept_bridge_base] }
        before do
          sorted_parents.shuffle.each do |parent|
            subject.store_parent(parent)
          end
        end
        it { expect(subject.sorted_parents).to eq(sorted_parents) }
      end

      describe 'dependency tree position properties' do
        shared_examples_for :store_one_parent_before do
          before { dept_methyl_on_bridge_base.store_parent(dept_bridge_base) }
        end

        shared_examples_for :store_many_parent_before do
          before do
            dept_methyl_on_dimer_base.store_parent(dept_bridge_base)
            dept_methyl_on_dimer_base.store_parent(dept_methyl_on_bridge_base)
          end
        end

        describe '#source?' do
          it { expect(dept_bridge_base.source?).to be_truthy }
          it_behaves_like :store_one_parent_before do
            it { expect(dept_methyl_on_bridge_base.source?).to be_falsey }
          end
          it_behaves_like :store_many_parent_before do
            it { expect(dept_methyl_on_dimer_base.source?).to be_falsey }
          end
        end

        describe '#complex?' do
          it { expect(dept_bridge_base.complex?).to be_falsey }
          it_behaves_like :store_one_parent_before do
            it { expect(dept_methyl_on_bridge_base.complex?).to be_falsey }
          end
          it_behaves_like :store_many_parent_before do
            it { expect(dept_methyl_on_dimer_base.complex?).to be_truthy }
          end
        end
      end
    end

  end
end
