require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe DependentWrappedSpec, type: :organizer do
      subject { described_class.new(bridge_base) }

      describe '#initialize' do
        describe '#straighten_graph' do
          it_behaves_like :count_atoms_and_relations_and_parents do
            let(:atoms_num) { 3 }
            let(:relations_num) { 10 }
            let(:parents_num) { 0 }
          end
        end
      end

      describe '#gas?' do
        it { expect(subject.gas?).to eq(subject.spec.gas?) }
      end

      describe '#external_bonds' do
        it { expect(subject.external_bonds).to eq(subject.spec.external_bonds) }
      end

      describe '#anchors' do
        it { expect(subject.anchors).to match_array(subject.spec.links.keys) }
      end

      describe '#source? && #complex?' do
        describe 'without parents and childrens' do
          it { expect(dept_bridge_base.source?).to be_truthy }
          it { expect(dept_bridge_base.complex?).to be_falsey }
        end

        describe 'one parent' do
          it_behaves_like :organize_dependencies do
            subject { dept_methyl_on_bridge_base }
            let(:others) { [dept_bridge_base] }

            it { expect(subject.source?).to be_falsey }
            it { expect(subject.complex?).to be_falsey }
          end
        end

        describe 'many parents' do
          it_behaves_like :organize_dependencies do
            subject { dept_methyl_on_dimer_base }
            let(:others) { [dept_bridge_base, dept_methyl_on_bridge_base] }

            it { expect(subject.source?).to be_falsey }
            it { expect(subject.complex?).to be_truthy }
          end
        end
      end
    end

  end
end
