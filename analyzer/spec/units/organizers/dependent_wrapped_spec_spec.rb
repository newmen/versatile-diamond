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
            clone.links.flat_map { |atom, rels| [atom] + rels.map(&:first) }
          end

          it { expect(atoms.uniq.select { |a| new_spec.keyname(a) }.size).to eq(3) }
        end
      end

      describe '#atoms' do
        it { expect(dept_bridge_base.atoms).to eq(dept_bridge_base.links.keys) }
      end

      describe '#anchors' do
        shared_examples_for :check_anchors do
          before do
            unless specific_specs.empty?
              base_cache = Hash[base_specs.map { |s| [s.name, s] }]
              organize_specific_specs_dependencies!(base_cache, specific_specs)
            end
            organize_base_specs_dependencies!(base_specs)
          end

          let(:specific_specs) { [] }
          let(:akns) { target_spec.anchors.map { |kn| target_spec.spec.keyname(kn) } }
          it { expect(akns).to match_array(keynames) }
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

        describe 'different methyl on dimer' do
          let(:target_spec) { dept_methyl_on_dimer_base }

          it_behaves_like :check_anchors do
            let(:base_specs) { [subject, dept_methyl_on_bridge_base, target_spec] }
            let(:keynames) { [:cr, :cl] }
          end

          it_behaves_like :check_anchors do
            before do
              dept_cbods.store_reaction(dept_cbod_drop)
              exchange_specs({}, dept_cbods, dept_cross_bridge_on_dimers_base)
            end
            let(:dept_cbods) { DependentSpecificSpec.new(cbod_drop.source.first) }
            let(:base_specs) do
              [
                subject,
                dept_methyl_on_bridge_base,
                target_spec,
                dept_cross_bridge_on_dimers_base
              ]
            end
            let(:keynames) { [:cr, :cl, :cm] }
          end
        end

        describe 'different bases for vinyl on dimer' do
          let(:target_spec) { dept_vinyl_on_dimer_base }
          let(:keynames) { [:cr, :cl] }

          it_behaves_like :check_anchors do
            let(:base_specs) do
              [subject, dept_vinyl_on_bridge_base, target_spec]
            end
          end

          it_behaves_like :check_anchors do
            let(:base_specs) do
              [
                subject,
                dept_methyl_on_bridge_base,
                dept_vinyl_on_bridge_base,
                target_spec
              ]
            end
          end
        end

        it_behaves_like :check_anchors do
          let(:base_specs) { [subject, dept_methyl_on_dimer_base] }
          let(:specific_specs) { [target_spec] }
          let(:target_spec) { dept_activated_methyl_on_dimer }
          let(:keynames) { [:cm] }
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

        describe 'different cross bridge on dimers' do
          let(:target_spec) { dept_cross_bridge_on_dimers_base }

          it_behaves_like :check_anchors do
            let(:base_specs) { [subject, dept_methyl_on_dimer_base, target_spec] }
            let(:keynames) { [:cm, :ctl, :ctr, :csl, :csr] }
          end

          it_behaves_like :check_anchors do
            let(:base_specs) do
              [
                subject,
                dept_methyl_on_bridge_base,
                dept_cross_bridge_on_bridges_base,
                target_spec
              ]
            end
            let(:keynames) { [:ctl, :ctr, :csl, :csr] }
          end
        end

        it_behaves_like :check_anchors do
          let(:base_specs) { [subject, dept_extended_bridge_base] }
          let(:specific_specs) { [dept_right_activated_extended_bridge, target_spec] }
          let(:target_spec) { dept_bottom_activated_incoherent_extended_bridge }
          let(:keynames) { [:cr] }
        end

        it_behaves_like :check_anchors do
          let(:base_specs) { [subject, dept_methyl_on_right_bridge_base, target_spec] }
          let(:target_spec) { dept_lower_methyl_on_half_extended_bridge_base }
          let(:keynames) { [:cr, :cbr] }
        end

        it_behaves_like :check_anchors do
          let(:base_specs) { [subject, dept_methyl_on_bridge_base, target_spec] }
          let(:target_spec) { dept_intermed_migr_down_bridge_base }
          let(:keynames) { [:cm, :cbt, :cbr] }
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

      describe '#common_atoms_with' do
        before do
          organize_base_specs_dependencies!(base_specs)
          organize_specific_specs_dependencies!(make_cache(base_specs), specific_specs)
        end

        describe 'direct dependence' do
          let(:base_specs) { [parent, dept_methyl_on_bridge_base] }
          let(:specific_specs) { [child] }

          let(:parent) { dept_bridge_base }
          let(:child) { dept_activated_methyl_on_bridge }
          let(:ps) { parent.spec }
          let(:cs) { child.spec }
          let(:cs_to_ps) do
            [
              [cs.atom(:cb), ps.atom(:ct)],
              [cs.atom(:cl), ps.atom(:cl)],
              [cs.atom(:cr), ps.atom(:cr)]
            ]
          end

          describe 'parent as argument' do
            it { expect(child.common_atoms_with(parent)).to match_array(cs_to_ps) }
          end

          describe 'child as argument' do
            let(:ps_to_cs) { cs_to_ps.map(&:rotate) }
            it { expect(parent.common_atoms_with(child)).to match_array(ps_to_cs) }
          end
        end

        describe 'cross dependencies' do
          let(:base_specs) { [dept_bridge_base, dept_methyl_on_bridge_base, d1] }
          let(:specific_specs) { [d2] }

          let(:d1) { dept_dimer_base }
          let(:d2) { dept_activated_methyl_on_bridge }
          let(:c1) { d1.spec }
          let(:c2) { d2.spec }
          let(:d1_to_d2) do
            [
              [c1.atom(:cr), c2.atom(:cb)],
              [c1.atom(:crb), c2.atom(:cl)],
              [c1.atom(:_cr0), c2.atom(:cr)],
              [c1.atom(:cl), c2.atom(:cb)],
              [c1.atom(:clb), c2.atom(:cr)],
              [c1.atom(:_cr1), c2.atom(:cl)],
            ]
          end

          describe 'd2 as argument' do
            it { expect(d1.common_atoms_with(d2)).to match_array(d1_to_d2) }
          end

          describe 'd1 as argument' do
            let(:d2_to_d1) { d1_to_d2.map(&:rotate) }
            it { expect(d2.common_atoms_with(d1)).to match_array(d2_to_d1) }
          end
        end
      end
    end

  end
end
