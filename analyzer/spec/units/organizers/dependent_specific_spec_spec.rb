require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe DependentSpecificSpec, type: :organizer do
      describe 'multi children spec' do
        let(:parent) { dept_dimer }
        let(:child) { dept_activated_dimer }

        it_behaves_like :multi_children
        it_behaves_like :wrapped_spec

        describe '#remove_child' do
          before do
            child.store_parent(parent)
            parent.remove_child(child)
          end

          it { expect(parent.children).to be_empty }
          it { expect(child.parent).to eq(parent) }
        end
      end

      it_behaves_like :residual_container do
        subject { dept_activated_methyl_on_bridge }
        let(:subtrahend) { dept_methyl_on_bridge }
      end

      subject { dept_activated_dimer }

      describe '#reduced' do
        it { expect(subject.reduced).to be_nil }
      end

      describe '#could_be_reduced?' do
        it { expect(subject.could_be_reduced?).to be_falsey }
      end

      describe '#specific_atoms' do
        it { expect(subject.specific_atoms).to eq(subject.spec.specific_atoms) }
      end

      describe '#name' do
        it { expect(subject.name).to eq(:'dimer(cr: *)') }
      end

      describe '#base_spec' do
        it { expect(subject.base_spec).to eq(subject.spec.spec) }
      end

      describe '#base_name' do
        it { expect(subject.base_name).to eq(subject.spec.spec.name) }
      end

      describe '#specific?' do
        it { expect(subject.specific?).to be_truthy }
        it { expect(dept_dimer.specific?).to be_falsey }
      end

      describe '#parent' do
        it { expect(subject.parent).to be_nil }
      end

      describe '#parents' do
        it { expect(subject.parents).to be_empty }

        describe 'parent presented' do
          before { subject.store_parent(dept_dimer) }
          it { expect(subject.parents).to eq([dept_dimer]) }
        end
      end

      describe 'parent operations' do
        let(:parent) { dept_bridge_base }
        let(:child) { dept_activated_bridge }
        before { child.store_parent(parent) }

        describe '#store_parent' do
          it { expect(parent.children).to eq([child]) }
          it { expect(child.parent).to eq(parent) }

          it { expect(child.rest).not_to be_nil }
        end

        describe '#remove_parent' do
          before { child.remove_parent(parent) }

          it { expect(parent.children).to eq([child]) }
          it { expect(child.parent).to be_nil }
        end

        describe '#replace_parent' do
          def store_and_restore
            subject.store_parent(old_base)
            subject.replace_parent(new_base)
          end

          def dept_amoib_dup
            described_class.new(activated_methyl_on_incoherent_bridge.dup)
          end

          subject { dept_amoib_dup }
          let(:old_base) { dept_methyl_on_bridge_base }
          let(:new_base) { dept_bridge_base_dup }

          describe 'without children' do
            before { store_and_restore }

            it { expect(subject.name).to eq(:'methyl_on_bridge(cm: *, t: i)') }
            it { expect(subject.base_spec).to eq(new_base.spec) }
            it { expect(subject.rest.atoms_num).to eq(2) }
          end

          describe 'children updates too' do
            let(:child1) { dept_amoib_dup }
            let(:child2) { dept_amoib_dup }

            before do
              subject.store_child(child1)
              subject.store_child(child2)
              store_and_restore
            end

            it { expect(child1.spec.atom(:t)).not_to be_nil }
            it { expect(child2.spec.atom(:cm)).not_to be_nil }
          end
        end
      end

      describe '# - ' do
        subject { minuend - subtrahend }
        let(:links) { subject.links }

        describe 'target is complex specific spec' do
          let(:minuend) { dept_activated_methyl_on_incoherent_bridge }

          describe 'parent links size less than current size' do
            let(:subtrahend) { dept_bridge_base_dup }

            it { should be_a(SpecResidual) }
            it { expect(subject.atoms_num).to eq(2) }
            it { expect(links.keys.map(&:actives)).to match_array([1, 0]) }
            it { expect(links.keys.map(&:incoherent?)).to match_array([false, true]) }
            it { expect(links.values.reduce(:+).map(&:last)).to match_array([
                free_bond, free_bond,
                bond_110_cross, bond_110_cross,
                active_bond, incoherent
              ]) }
          end
        end

        describe 'other is base with same links size' do
          let(:minuend) { dept_activated_methyl_on_bridge }
          let(:subtrahend) { dept_methyl_on_bridge_base }

          it { should be_a(SpecResidual) }
          it { expect(subject.atoms_num).to eq(1) }
          it { expect(links.keys.first.actives).to eq(1) }
          it { expect(subject.relations_num).to eq(2) }
        end

        describe 'hidrogenated parent' do
          let(:minuend) { dept_hydrogenated_bridge }
          let(:subtrahend) { dept_bridge_base_dup }

          it { expect(links.size).to eq(1) }
          it { expect(links.keys.first.monovalents).to eq([adsorbed_h]) }
        end

        describe 'resudue contain atoms with relevant states' do
          let(:minuend) { dept_methyl_on_incoherent_bridge }
          let(:subtrahend) { dept_methyl_on_bridge_base }

          it { expect(links.size).to eq(1) }
          it { expect(links.keys.first.incoherent?).to be_truthy }
        end

        describe 'correct relations after base spec change' do
          let(:minuend) { dept_activated_methyl_on_right_bridge }
          let(:subtrahend) { dept_bridge_base_dup }
          let(:cb) { subject.links.keys.last }
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
        subject { dept_methyl_on_dimer_base }
        let(:atom) { methyl_on_dimer_base.atom(:cr) }
        let(:rls) do
          [bond_100_front, bond_110_cross, bond_110_cross, free_bond]
        end
      end

      describe '#size' do
        it { expect(subject.size).to eq(10) }
        it { expect(dept_activated_incoherent_bridge.size).to eq(11) }
      end

      describe '#organize_dependencies!' do
        let(:dependent_bases) do
          [dept_bridge_base, dept_methyl_on_bridge_base, dept_dimer_base]
        end
        let(:base_cache) { make_cache(dependent_bases) }

        shared_examples_for :organize_and_check do
          let(:main) { [target] + addition }

          before do
            (main + children).map do |cld|
              cld.organize_dependencies!(base_cache, similars)
            end
          end

          it { expect(target.parent).to eq(parent) }
          it { expect(target.children).to match_array(children) }
        end

        shared_examples_for :organize_and_check_base_parent do
          it_behaves_like :organize_and_check do
            let(:addition) { [] }
          end
        end

        shared_examples_for :organize_and_check_specific_parent do
          it_behaves_like :organize_and_check do
            let(:addition) { [parent] }
          end
        end

        describe 'bridge' do
          let(:similars) do
            [
              dept_bridge,
              dept_activated_bridge,
              dept_activated_incoherent_bridge,
              dept_extra_activated_bridge
            ]
          end

          it_behaves_like :organize_and_check_base_parent do
            let(:target) { dept_bridge }
            let(:parent) { dept_bridge_base }
            let(:children) { [dept_activated_bridge] }
          end

          it_behaves_like :organize_and_check_specific_parent do
            let(:target) { dept_activated_bridge }
            let(:parent) { dept_bridge }
            let(:children) { [dept_activated_incoherent_bridge] }
          end

          it_behaves_like :organize_and_check_specific_parent do
            let(:target) { dept_activated_incoherent_bridge }
            let(:parent) { dept_activated_bridge }
            let(:children) { [dept_extra_activated_bridge] }
          end

          it_behaves_like :organize_and_check_specific_parent do
            let(:target) { dept_extra_activated_bridge }
            let(:parent) { dept_activated_incoherent_bridge }
            let(:children) { [] }
          end
        end

        describe 'methyl on bridge' do
          let(:similars) do
            [
              dept_methyl_on_bridge,
              dept_activated_methyl_on_bridge,
              dept_methyl_on_activated_bridge,
              dept_methyl_on_incoherent_bridge,
              dept_unfixed_methyl_on_bridge,
              dept_activated_methyl_on_incoherent_bridge,
              dept_unfixed_activated_methyl_on_incoherent_bridge
            ]
          end

          it_behaves_like :organize_and_check_base_parent do
            let(:target) { dept_methyl_on_bridge }
            let(:parent) { dept_methyl_on_bridge_base }
            let(:children) do
              [
                dept_activated_methyl_on_bridge,
                dept_methyl_on_incoherent_bridge,
                dept_unfixed_methyl_on_bridge
              ]
            end
          end

          it_behaves_like :organize_and_check_specific_parent do
            let(:target) { dept_activated_methyl_on_bridge }
            let(:parent) { dept_methyl_on_bridge }
            let(:children) { [dept_activated_methyl_on_incoherent_bridge] }
          end

          it_behaves_like :organize_and_check_specific_parent do
            let(:target) { dept_activated_methyl_on_incoherent_bridge }
            let(:parent) { dept_activated_methyl_on_bridge }
            let(:children) { [dept_unfixed_activated_methyl_on_incoherent_bridge] }
          end

          it_behaves_like :organize_and_check_specific_parent do
            let(:target) { dept_unfixed_activated_methyl_on_incoherent_bridge }
            let(:parent) { dept_activated_methyl_on_incoherent_bridge }
            let(:children) { [] }
          end

          it_behaves_like :organize_and_check_specific_parent do
            let(:target) { dept_methyl_on_incoherent_bridge }
            let(:parent) { dept_methyl_on_bridge }
            let(:children) { [dept_methyl_on_activated_bridge] }
          end

          it_behaves_like :organize_and_check_specific_parent do
            let(:target) { dept_methyl_on_activated_bridge }
            let(:parent) { dept_methyl_on_incoherent_bridge }
            let(:children) { [] }
          end

          it_behaves_like :organize_and_check_specific_parent do
            let(:target) { dept_unfixed_methyl_on_bridge }
            let(:parent) { dept_methyl_on_bridge }
            let(:children) { [] }
          end
        end

        describe 'dimer' do
          let(:similars) { [dept_dimer, dept_activated_dimer] }

          it_behaves_like :organize_and_check_base_parent do
            let(:target) { dept_dimer }
            let(:parent) { dept_dimer_base }
            let(:children) { [dept_activated_dimer] }
          end

          it_behaves_like :organize_and_check_specific_parent do
            let(:target) { dept_activated_dimer }
            let(:parent) { dept_dimer }
            let(:children) { [] }
          end
        end
      end
    end

  end
end
