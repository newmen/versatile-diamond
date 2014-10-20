require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe DependentSpecificSpec, type: :organizer do
      it_behaves_like :minuend do
        subject { dept_activated_methyl_on_bridge }
        let(:bigger) { dept_activated_methyl_on_incoherent_bridge }

        [:cm, :cb, :cr, :cl].each do |kn|
          let(kn) { activated_methyl_on_bridge.atom(kn) }
        end

        let(:atom) { cm }
        let(:atom_relations) { [free_bond, active_bond] }
        let(:clean_links) do
          {
            cm => [[cb, free_bond]],
            cb => [[cm, free_bond], [cr, bond_110_cross], [cl, bond_110_cross]],
            cr => [[cb, bond_110_front]],
            cl => [[cb, bond_110_front]]
          }
        end
      end

      it_behaves_like :wrapped_spec do
        subject { dept_activated_methyl_on_bridge }
        let(:child) { dept_activated_methyl_on_incoherent_bridge }
      end

      it_behaves_like :count_atoms_and_relations_and_parents do
        subject { dept_activated_methyl_on_incoherent_bridge - dept_bridge_base_dup }
        let(:atoms_num) { 2 }
        let(:relations_num) { 6 }
        let(:parents_num) { 1 }

        let(:links) { subject.links }
        it { expect(links.keys.map(&:actives)).to match_array([1, 0]) }
        it { expect(links.keys.map(&:incoherent?)).to match_array([false, true]) }
      end

      it_behaves_like :parents_with_twins do
        subject { dept_activated_methyl_on_incoherent_bridge }
        let(:others) { [dept_methyl_on_bridge_base, dept_activated_methyl_on_bridge] }
        let(:atom) { activated_methyl_on_incoherent_bridge.atom(:cb) }
        let(:parents_with_twins) do
          [
            [dept_activated_methyl_on_bridge, activated_methyl_on_bridge.atom(:cb)]
          ]
        end
      end

      describe '#reduced' do
        it { expect(dept_activated_dimer.reduced).to be_nil }
      end

      describe '#could_be_reduced?' do
        it { expect(dept_activated_dimer.could_be_reduced?).to be_falsey }
      end

      describe '#name' do
        it { expect(dept_activated_dimer.name).to eq(:'dimer(cr: *)') }
      end

      describe '#base_name' do
        it { expect(dept_activated_dimer.base_name).to eq(:dimer) }
      end

      describe '#specific?' do
        it { expect(dept_activated_dimer.specific?).to be_truthy }
        it { expect(dept_dimer.specific?).to be_falsey }
      end

      describe '#replace_base_spec' do
        subject { dept_activated_methyl_on_incoherent_bridge }
        let(:old_base) { dept_methyl_on_bridge_base }
        let(:new_base) { dept_bridge_base_dup }

        shared_examples_for :check_replacing do
          before { subject.replace_base_spec(new_base) }
          it { expect(subject.spec.spec).to eq(new_base.spec) }
          it { expect(subject.parents.first).to eq(new_base) }
        end

        it_behaves_like :organize_dependencies do
          let(:others) { [old_base] }
          it_behaves_like :check_replacing do
            it { expect(subject.name).to eq(:'methyl_on_bridge(cm: *, t: i)') }
          end
        end

        it_behaves_like :organize_dependencies do
          let(:others) { [old_base, child] }
          let(:child) { dept_unfixed_activated_methyl_on_incoherent_bridge }
          it_behaves_like :check_replacing do
            it { expect(child.spec.atom(:t)).not_to be_nil }
            it { expect(child.spec.atom(:cm)).not_to be_nil }
          end
        end
      end

      describe '#organize_dependencies!' do
        shared_examples_for :organize_and_check do
          it_behaves_like :organize_dependencies do
            let(:others) { [parent] + children + similars }
            it { expect(subject.parents.first).to eq(parent) }
            it { expect(subject.children).to match_array(children) }
          end
        end

        describe 'bridge' do
          let(:similars) do
            [
              dept_bridge_base,
              dept_activated_bridge,
              dept_activated_incoherent_bridge,
              dept_extra_activated_bridge
            ]
          end

          it_behaves_like :organize_and_check do
            subject { dept_activated_bridge }
            let(:parent) { dept_bridge_base }
            let(:children) { [dept_activated_incoherent_bridge] }
          end

          it_behaves_like :organize_and_check do
            subject { dept_activated_incoherent_bridge }
            let(:parent) { dept_activated_bridge }
            let(:children) { [dept_extra_activated_bridge] }
          end

          it_behaves_like :organize_and_check do
            subject { dept_extra_activated_bridge }
            let(:parent) { dept_activated_incoherent_bridge }
            let(:children) { [] }
          end
        end

        describe 'methyl on bridge' do
          let(:similars) do
            [
              dept_methyl_on_bridge_base,
              dept_activated_methyl_on_bridge,
              dept_methyl_on_activated_bridge,
              dept_methyl_on_incoherent_bridge,
              dept_unfixed_methyl_on_bridge,
              dept_activated_methyl_on_incoherent_bridge,
              dept_unfixed_activated_methyl_on_incoherent_bridge
            ]
          end

          it_behaves_like :organize_and_check do
            subject { dept_activated_methyl_on_bridge }
            let(:parent) { dept_methyl_on_bridge_base }
            let(:children) { [dept_activated_methyl_on_incoherent_bridge] }
          end

          it_behaves_like :organize_and_check do
            subject { dept_unfixed_activated_methyl_on_incoherent_bridge }
            let(:parent) { dept_activated_methyl_on_incoherent_bridge }
            let(:children) { [] }
          end

          it_behaves_like :organize_and_check do
            subject { dept_unfixed_methyl_on_bridge }
            let(:parent) { dept_methyl_on_bridge_base }
            let(:children) { [] }
          end

          it_behaves_like :organize_and_check do
            subject { dept_activated_methyl_on_incoherent_bridge }
            let(:parent) { dept_activated_methyl_on_bridge }
            let(:children) { [dept_unfixed_activated_methyl_on_incoherent_bridge] }
          end

          it_behaves_like :organize_and_check do
            subject { dept_methyl_on_incoherent_bridge }
            let(:parent) { dept_methyl_on_bridge_base }
            let(:children) { [dept_methyl_on_activated_bridge] }
          end

          it_behaves_like :organize_and_check do
            subject { dept_methyl_on_activated_bridge }
            let(:parent) { dept_methyl_on_incoherent_bridge }
            let(:children) { [] }
          end
        end

        describe 'dimer' do
          let(:similars) { [dept_dimer_base, dept_activated_dimer] }

          it_behaves_like :organize_and_check do
            subject { dept_activated_dimer }
            let(:parent) { dept_dimer_base }
            let(:children) { [] }
          end
        end
      end
    end

  end
end
