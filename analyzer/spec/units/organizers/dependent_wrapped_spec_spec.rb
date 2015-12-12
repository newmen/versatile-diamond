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
        shared_examples_for :check_anchors do
          before { organize_base_specs_dependencies!(base_specs) }
          let(:anchors) { keynames.map { |kn| target_spec.spec.atom(kn) } }
          it { expect(target_spec.anchors).to match_array(anchors) }
        end

        it_behaves_like :check_anchors do
          let(:base_specs) { [subject] }
          let(:target_spec) { subject }
          let(:keynames) do
            subject.spec.links.keys.map { |a| subject.spec.keyname(a) }
          end
        end

        it_behaves_like :check_anchors do
          let(:base_specs) { [subject, target_spec] }
          let(:target_spec) { dept_methyl_on_bridge_base }
          let(:keynames) { [:cb, :cm] }
        end

        it_behaves_like :check_anchors do
          let(:base_specs) { [subject, target_spec] }
          let(:target_spec) { dept_dimer_base }
          let(:keynames) { [:cr, :cl] }
        end

        it_behaves_like :check_anchors do
          let(:base_specs) { [subject, target_spec] }
          let(:target_spec) { dept_three_bridges_base }
          let(:keynames) { [:ct, :cc] }
        end

        it_behaves_like :check_anchors do
          let(:base_specs) { [subject, dept_dimer_base, target_spec] }
          let(:target_spec) { dept_bridge_with_dimer_base }
          let(:keynames) { [:ct, :cr] }
        end

        it_behaves_like :check_anchors do
          let(:base_specs) { [subject, dept_methyl_on_bridge_base, target_spec] }
          let(:target_spec) { dept_cross_bridge_on_bridges_base }
          let(:keynames) { [:ctl, :cm, :ctr] }
        end

        it_behaves_like :check_anchors do
          let(:base_specs) { [subject, dept_methyl_on_dimer_base, target_spec] }
          let(:target_spec) { dept_cross_bridge_on_dimers_base }
          let(:keynames) { [:cm, :ctl, :ctr, :csl, :csr] }
        end

        it_behaves_like :check_anchors do
          let(:base_specs) { [subject, dept_methyl_on_right_bridge_base, target_spec] }
          let(:target_spec) { dept_lower_methyl_on_half_extended_bridge_base }
          let(:keynames) { [:cr, :cbr] }
        end

        describe 'undependent from parents species set' do
          let(:target_spec) { dept_intermed_migr_down_common_base }
          let(:keynames) { [:cm, :cdr, :cbr] }

          it_behaves_like :check_anchors do
            let(:base_specs) do
              [dept_methyl_on_bridge_base, dept_methyl_on_dimer_base, target_spec]
            end
          end

          it_behaves_like :check_anchors do
            let(:base_specs) do
              [
                subject,
                dept_methyl_on_bridge_base,
                dept_methyl_on_dimer_base,
                target_spec
              ]
            end
          end
        end

        describe 'intermediate specie of migration down process' do
          let(:keynames) { [:cdr, :cbr, :cdl, :cbl, :cm] }
          let(:base_specs) do
            [
              subject,
              dept_methyl_on_bridge_base,
              dept_methyl_on_dimer_base,
              target_spec
            ]
          end

          it_behaves_like :check_anchors do
            let(:target_spec) { dept_intermed_migr_down_half_base }
          end

          it_behaves_like :check_anchors do
            let(:target_spec) { dept_intermed_migr_down_full_base }
          end
        end
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
    end

  end
end
