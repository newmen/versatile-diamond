require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe DependentSpecificSpec do
      subject { described_class.new(activated_dimer) }

      describe '#reduced' do
        it { expect(subject.reduced).to be_nil }
      end

      describe '#could_be_reduced?' do
        it { expect(subject.could_be_reduced?).to be_false }
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
        it { expect(subject.specific?).to be_true }
      end

      describe 'default' do
        describe '#parent state' do
          it { expect(subject.parent).to be_nil }
        end

        describe '#childs state' do
          it { expect(subject.childs).to be_empty }
        end

        describe '#reactions state' do
          it { expect(subject.reactions).to be_empty }
        end

        describe '#theres state' do
          it { expect(subject.theres).to be_empty }
        end
      end

      describe '#store_child' do
        let(:child) { described_class.new(methyl_on_dimer) }
        before { subject.store_child(child) }
        it { expect(subject.childs).to eq([child]) }
      end

      describe '#store_reaction' do
        let(:reaction) { DependentReaction.new(dimer_formation) }
        before { subject.store_reaction(reaction) }
        it { expect(subject.reactions).to eq([reaction]) }
      end

      describe '#store_there' do
        let(:there) { DependentThere.new(on_end) }
        before { subject.store_there(there) }
        it { expect(subject.theres).to eq([there]) }
      end

      describe '#size' do
        it { expect(subject.size).to eq(10) }
        it { expect(described_class.new(activated_incoherent_bridge).size).to eq(11) }
      end

      describe '#organize_dependencies!' do
        let(:base_specs) do
          [bridge_base, methyl_on_bridge_base, dimer_base]
        end
        let(:dependent_bases) { base_specs.map { |bs| DependentBaseSpec.new(bs) } }
        let(:base_cache) { Hash[base_specs.map(&:name).zip(dependent_bases)] }

        shared_examples_for :organize_and_check do
          let(:instance) { described_class.new(target) }
          let(:inst_parent) { parent && described_class.new(parent) }
          let(:inst_childs) { childs.map { |s| described_class.new(s) } }

          let(:remain) { similars - [target, parent] - childs }
          let(:main) { (parent ? [inst_parent] : []) + [instance] }
          let(:others) do
            main + inst_childs + remain.map { |s| described_class.new(s) }
          end

          before do
            (main + inst_childs).map do |cld|
              cld.organize_dependencies!(base_cache, others)
            end
          end

          it { expect(instance.parent).to eq(inst_parent) }
          it { expect(instance.childs).to match_array(inst_childs) }
        end

        describe 'bridge' do
          let(:similars) { [bridge, activated_bridge,
            activated_incoherent_bridge, extra_activated_bridge] }

          it_behaves_like :organize_and_check do
            let(:target) { bridge }
            let(:parent) { nil }
            let(:childs) { [activated_bridge] }
          end

          it_behaves_like :organize_and_check do
            let(:target) { activated_bridge }
            let(:parent) { bridge }
            let(:childs) { [activated_incoherent_bridge] }
          end

          it_behaves_like :organize_and_check do
            let(:target) { activated_incoherent_bridge }
            let(:parent) { activated_bridge }
            let(:childs) { [extra_activated_bridge] }
          end

          it_behaves_like :organize_and_check do
            let(:target) { extra_activated_bridge }
            let(:parent) { activated_incoherent_bridge }
            let(:childs) { [] }
          end
        end

        describe 'methyl on bridge' do
          let(:similars) { [methyl_on_bridge, activated_methyl_on_bridge,
            methyl_on_activated_bridge, methyl_on_incoherent_bridge,
            unfixed_methyl_on_bridge, activated_methyl_on_incoherent_bridge,
            unfixed_activated_methyl_on_incoherent_bridge] }

          it_behaves_like :organize_and_check do
            let(:target) { methyl_on_bridge }
            let(:parent) { nil }
            let(:childs) do
              [
                activated_methyl_on_bridge,
                methyl_on_incoherent_bridge,
                unfixed_methyl_on_bridge
              ]
            end
          end

          it_behaves_like :organize_and_check do
            let(:target) { activated_methyl_on_bridge }
            let(:parent) { methyl_on_bridge }
            let(:childs) { [activated_methyl_on_incoherent_bridge] }
          end

          it_behaves_like :organize_and_check do
            let(:target) { activated_methyl_on_incoherent_bridge }
            let(:parent) { activated_methyl_on_bridge }
            let(:childs) { [unfixed_activated_methyl_on_incoherent_bridge] }
          end

          it_behaves_like :organize_and_check do
            let(:target) { unfixed_activated_methyl_on_incoherent_bridge }
            let(:parent) { activated_methyl_on_incoherent_bridge }
            let(:childs) { [] }
          end

          it_behaves_like :organize_and_check do
            let(:target) { methyl_on_incoherent_bridge }
            let(:parent) { methyl_on_bridge }
            let(:childs) { [methyl_on_activated_bridge] }
          end

          it_behaves_like :organize_and_check do
            let(:target) { methyl_on_activated_bridge }
            let(:parent) { methyl_on_incoherent_bridge }
            let(:childs) { [] }
          end

          it_behaves_like :organize_and_check do
            let(:target) { unfixed_methyl_on_bridge }
            let(:parent) { methyl_on_bridge }
            let(:childs) { [] }
          end
        end

        describe 'dimer' do
          let(:similars) { [dimer, activated_dimer] }

          it_behaves_like :organize_and_check do
            let(:target) { dimer }
            let(:parent) { nil }
            let(:childs) { [activated_dimer] }
          end

          it_behaves_like :organize_and_check do
            let(:target) { activated_dimer }
            let(:parent) { dimer }
            let(:childs) { [] }
          end
        end
      end
    end

  end
end
