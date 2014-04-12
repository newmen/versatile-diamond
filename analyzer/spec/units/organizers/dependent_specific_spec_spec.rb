require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe DependentSpecificSpec do
      def wrap(spec)
        described_class.new(spec)
      end

      it_behaves_like :multi_children do
        let(:parent) { wrap(dimer) }
        let(:child) { wrap(activated_dimer) }
      end

      subject { wrap(activated_dimer) }

      describe '#reduced' do
        it { expect(subject.reduced).to be_nil }
      end

      describe '#could_be_reduced?' do
        it { expect(subject.could_be_reduced?).to be_false }
      end

      describe '#specific_atoms' do
        it { expect(subject.specific_atoms).to eq(subject.spec.specific_atoms) }
      end

      describe '#active_bonds_num' do
        it { expect(subject.active_bonds_num).to eq(subject.spec.active_bonds_num) }
      end

      describe '#replace_base_spec' do
        let(:cap) { bridge_base }
        before { subject.replace_base_spec(cap) }
        it { expect(subject.base_spec).to eq(cap) }
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
        it { expect(subject.specific?).to be_true }
        it { expect(wrap(dimer).specific?).to be_false }
      end

      describe '#parent' do
        it { expect(subject.parent).to be_nil }
      end

      describe '#store_parent' do
        let(:parent) { DependentBaseSpec.new(bridge_base) }
        let(:child) { wrap(activated_bridge) }

        before { child.store_parent(parent) }

        it { expect(parent.children).to eq([child]) }
        it { expect(child.parent).to eq(parent) }
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
