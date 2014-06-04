require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe DependentSpecificSpec do
      def wrap(spec)
        described_class.new(spec)
      end

      describe 'multi children spec' do
        let(:parent) { wrap(dimer) }
        let(:child) { wrap(activated_dimer) }

        it_behaves_like :multi_children

        describe '#remove_child' do
          before do
            child.store_parent(parent)
            parent.remove_child(child)
          end

          it { expect(parent.children).to be_empty }
          it { expect(child.parent).to eq(parent) }
        end
      end

      subject { wrap(activated_dimer) }

      describe '#rest' do
        it { expect(subject.rest).to be_nil }
      end

      describe '#store_rest' do
        subject { wrap(activated_methyl_on_bridge) }
        let(:parent) { wrap(methyl_on_bridge) }
        let(:rest) { subject - parent }
        before { subject.store_rest(rest) }
        it { expect(subject.rest).to eq(rest) }
      end

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
        it { expect(wrap(dimer).specific?).to be_falsey }
      end

      describe '#parent' do
        it { expect(subject.parent).to be_nil }
      end

      describe 'parent operations' do
        let(:parent) { DependentBaseSpec.new(bridge_base) }
        let(:child) { wrap(activated_bridge) }
        before { child.store_parent(parent) }

        describe '#store_parent' do
          it { expect(parent.children).to eq([child]) }
          it { expect(child.parent).to eq(parent) }

          it { expect(child.rest).to_not be_nil }
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

          subject { wrap(activated_methyl_on_incoherent_bridge.dup) }
          let(:old_base) { DependentBaseSpec.new(methyl_on_bridge_base) }
          let(:new_base) { DependentBaseSpec.new(bridge_base_dup) }

          describe 'without children' do
            before { store_and_restore }

            it { expect(subject.name).to eq(:'methyl_on_bridge(cm: *, t: i)') }
            it { expect(subject.base_spec).to eq(new_base.spec) }
            it { expect(subject.rest.atoms_num).to eq(2) }
          end

          describe 'children updates too' do
            let(:child1) { wrap(activated_methyl_on_incoherent_bridge.dup) }
            let(:child2) { wrap(activated_methyl_on_incoherent_bridge.dup) }

            before do
              subject.store_child(child1)
              subject.store_child(child2)
              store_and_restore
            end

            it { expect(child1.spec.atom(:t)).to_not be_nil }
            it { expect(child2.spec.atom(:cm)).to_not be_nil }
          end
        end
      end

      describe '# - ' do
        subject { minuend - subtrahend }
        let(:links) { subject.links }

        describe 'target is complex specific spec' do
          let(:minuend) { wrap(activated_methyl_on_incoherent_bridge) }

          describe 'parent links size less than current size' do
            let(:subtrahend) { DependentBaseSpec.new(bridge_base_dup) }

            it { should be_a(SpecResidual) }
            it { expect(subject.atoms_num).to eq(2) }
            it { expect(links.keys.map(&:actives)).to match_array([1, 0]) }
            it { expect(links.keys.map(&:incoherent?)).to match_array([false, true]) }
            it { expect(links.values.reduce(:+).map(&:last)).to match_array([
                free_bond, free_bond,
                bond_110_cross, bond_110_cross,
                :active, :incoherent
              ]) }
          end
        end

        describe 'other is base with same links size' do
          let(:minuend) { wrap(activated_methyl_on_bridge) }
          let(:subtrahend) { DependentBaseSpec.new(methyl_on_bridge_base) }

          it { should be_a(SpecResidual) }
          it { expect(subject.atoms_num).to eq(1) }
          it { expect(links.keys.first.actives).to eq(1) }
          it { expect(subject.relations_num).to eq(2) }
        end

        describe 'hidrogenated parent' do
          let(:minuend) { wrap(hydrogenated_bridge) }
          let(:subtrahend) { DependentBaseSpec.new(bridge_base_dup) }

          it { expect(links.size).to eq(1) }
          it { expect(links.keys.first.monovalents).to eq([:H]) }
        end

        describe 'resudue contain atoms with relevant states' do
          let(:minuend) { wrap(methyl_on_incoherent_bridge) }
          let(:subtrahend) { DependentBaseSpec.new(methyl_on_bridge_base) }

          it { expect(links.size).to eq(1) }
          it { expect(links.keys.first.incoherent?).to be_truthy }
        end

        describe 'correct relations after base spec change' do
          let(:minuend) { wrap(activated_methyl_on_right_bridge) }
          let(:subtrahend) { DependentBaseSpec.new(bridge_base_dup) }
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
        let(:spec) { methyl_on_dimer_base }
        let(:atom) { spec.atom(:cr) }
        let(:rls) do
          [bond_100_front, bond_110_cross, bond_110_cross, free_bond]
        end
      end

      describe '#size' do
        it { expect(subject.size).to eq(10) }
        it { expect(wrap(activated_incoherent_bridge).size).to eq(11) }
      end

      describe '#organize_dependencies!' do
        let(:base_specs) do
          [bridge_base, methyl_on_bridge_base, dimer_base]
        end
        let(:dependent_bases) { base_specs.map { |bs| DependentBaseSpec.new(bs) } }
        let(:base_cache) { Hash[base_specs.map(&:name).zip(dependent_bases)] }

        shared_examples_for :organize_and_check do
          let(:instance) { wrap(target) }
          let(:inst_children) { children.map { |s| wrap(s) } }

          let(:remain) { similars - children - without - [target] }
          let(:main) { [instance] + with }
          let(:others) { main + inst_children + remain.map { |s| wrap(s) } }

          before do
            (main + inst_children).map do |cld|
              cld.organize_dependencies!(base_cache, others)
            end
          end

          it { expect(instance.parent).to eq(inst_parent) }
          it { expect(instance.children).to match_array(inst_children) }
        end

        shared_examples_for :organize_and_check_base_parent do
          it_behaves_like :organize_and_check do
            let(:inst_parent) { base_cache[parent.name] }
            let(:without) { [] }
            let(:with) { [] }
          end
        end

        shared_examples_for :organize_and_check_specific_parent do
          it_behaves_like :organize_and_check do
            let(:inst_parent) { wrap(parent) }
            let(:without) { [parent] }
            let(:with) { [inst_parent] }
          end
        end

        describe 'bridge' do
          let(:similars) { [bridge, activated_bridge,
            activated_incoherent_bridge, extra_activated_bridge] }

          it_behaves_like :organize_and_check_base_parent do
            let(:target) { bridge }
            let(:parent) { bridge_base }
            let(:children) { [activated_bridge] }
          end

          it_behaves_like :organize_and_check_specific_parent do
            let(:target) { activated_bridge }
            let(:parent) { bridge }
            let(:children) { [activated_incoherent_bridge] }
          end

          it_behaves_like :organize_and_check_specific_parent do
            let(:target) { activated_incoherent_bridge }
            let(:parent) { activated_bridge }
            let(:children) { [extra_activated_bridge] }
          end

          it_behaves_like :organize_and_check_specific_parent do
            let(:target) { extra_activated_bridge }
            let(:parent) { activated_incoherent_bridge }
            let(:children) { [] }
          end
        end

        describe 'methyl on bridge' do
          let(:similars) { [methyl_on_bridge, activated_methyl_on_bridge,
            methyl_on_activated_bridge, methyl_on_incoherent_bridge,
            unfixed_methyl_on_bridge, activated_methyl_on_incoherent_bridge,
            unfixed_activated_methyl_on_incoherent_bridge] }

          it_behaves_like :organize_and_check_base_parent do
            let(:target) { methyl_on_bridge }
            let(:parent) { methyl_on_bridge_base }
            let(:children) do
              [
                activated_methyl_on_bridge,
                methyl_on_incoherent_bridge,
                unfixed_methyl_on_bridge
              ]
            end
          end

          it_behaves_like :organize_and_check_specific_parent do
            let(:target) { activated_methyl_on_bridge }
            let(:parent) { methyl_on_bridge }
            let(:children) { [activated_methyl_on_incoherent_bridge] }
          end

          it_behaves_like :organize_and_check_specific_parent do
            let(:target) { activated_methyl_on_incoherent_bridge }
            let(:parent) { activated_methyl_on_bridge }
            let(:children) { [unfixed_activated_methyl_on_incoherent_bridge] }
          end

          it_behaves_like :organize_and_check_specific_parent do
            let(:target) { unfixed_activated_methyl_on_incoherent_bridge }
            let(:parent) { activated_methyl_on_incoherent_bridge }
            let(:children) { [] }
          end

          it_behaves_like :organize_and_check_specific_parent do
            let(:target) { methyl_on_incoherent_bridge }
            let(:parent) { methyl_on_bridge }
            let(:children) { [methyl_on_activated_bridge] }
          end

          it_behaves_like :organize_and_check_specific_parent do
            let(:target) { methyl_on_activated_bridge }
            let(:parent) { methyl_on_incoherent_bridge }
            let(:children) { [] }
          end

          it_behaves_like :organize_and_check_specific_parent do
            let(:target) { unfixed_methyl_on_bridge }
            let(:parent) { methyl_on_bridge }
            let(:children) { [] }
          end
        end

        describe 'dimer' do
          let(:similars) { [dimer, activated_dimer] }

          it_behaves_like :organize_and_check_base_parent do
            let(:target) { dimer }
            let(:parent) { dimer_base }
            let(:children) { [activated_dimer] }
          end

          it_behaves_like :organize_and_check_specific_parent do
            let(:target) { activated_dimer }
            let(:parent) { dimer }
            let(:children) { [] }
          end
        end
      end
    end

  end
end
