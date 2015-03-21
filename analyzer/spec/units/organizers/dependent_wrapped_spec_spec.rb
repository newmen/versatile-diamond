require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe DependentWrappedSpec, type: :organizer do
      subject { dept_bridge_base }

      describe '#initialize' do
        describe '#straighten_graph' do
          it_behaves_like :count_atoms_and_relations_and_parents do
            let(:atoms_num) { 3 }
            let(:relations_num) { 10 }
            let(:parents_num) { 0 }
          end
        end
      end

      describe '#theres' do
        it { expect(subject.theres).to be_empty }
      end

      describe '#store_there' do
        let(:there) { dept_on_end }
        before { subject.store_there(there) }
        it { expect(subject.theres).to eq([there]) }
      end

      describe '#gas?' do
        it { expect(subject.gas?).to eq(subject.spec.gas?) }
      end

      describe '#external_bonds' do
        it { expect(subject.external_bonds).to eq(subject.spec.external_bonds) }
      end

      describe '#clone_with_replace' do
        let(:new_spec) { bridge_base_dup }
        let(:clone) { subject.clone_with_replace(new_spec) }
        let(:child) { dept_dimer_base }
        before { subject.store_child(child) }

        it { expect(clone).to be_a(described_class) }
        it { expect(clone).not_to eq(subject) }
        it { expect(subject).not_to eq(clone) }

        it { expect(subject.spec).not_to eq(new_spec) }
        it { expect(clone.spec).to eq(new_spec) }
        it { expect(clone.children).to eq([child]) }
        it { expect(clone.reactions).to be_empty }
        it { expect(clone.theres).to be_empty }

        describe 'different atoms' do
          let(:atoms) do
            clone.links.reduce([]) do |acc, (atom, rels)|
              acc + [atom] + rels.map(&:first)
            end
          end

          it { expect(atoms.uniq.select { |a| new_spec.keyname(a) }.size).to eq(3) }
        end
      end

      describe '#anchors' do
        it { expect(subject.anchors).to match_array(subject.spec.links.keys) }
      end

      describe '#source? && #complex?' do
        describe 'without parents and childrens' do
          it { expect(subject.source?).to be_truthy }
          it { expect(subject.complex?).to be_falsey }
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

      describe '#similar_wheres' do
        subject { dept_dimer }

        it { expect(subject.similar_wheres).to be_empty }

        describe 'there objects are presented' do
          before do
            subject.store_there(dept_on_end)
            subject.store_there(dept_on_middle)
          end
          it { expect(subject.similar_wheres).to eq([[at_end, at_middle]]) }
        end
      end

      describe '#root_wheres' do
        subject { dept_dimer }

        it { expect(subject.root_wheres).to be_empty }

        describe 'there objects are presented' do
          before do
            subject.store_there(dept_on_end)
            subject.store_there(dept_on_middle)
          end
          it { expect(subject.root_wheres).to eq([at_end]) }
        end
      end
    end

  end
end
