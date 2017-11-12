require 'spec_helper'

module VersatileDiamond
  module Generators
    module Formula

      describe LinksFixer, type: :organizer do
        subject { described_class }

        describe '#remove_excess' do
          shared_examples_for :check_excess do
            def verts_in(links)
              links.each_with_object(Set.new) do |(v1, rels), acc|
                acc << v1
                rels.each { |v2, _| acc << v2 if v2 }
              end
            end

            def rels_num(links)
              links.reduce(0) { |acc, (_, rels)| acc + rels.size }
            end

            let(:base_spec) { target_spec.spec }

            let(:fixed_links) { subject.remove_excess(target_links) }
            let(:target_links) { target_spec.links }

            let(:fixed_atoms) { verts_in(fixed_links) }
            let(:target_atoms) { verts_in(target_links) }
            let(:removed_atoms) { target_atoms - fixed_atoms }
            let(:diff_atoms) { removed_atoms.select(&base_spec.method(:keyname)) }
            it { expect(Set.new(diff_atoms)).to eq(Set.new(excess_atoms)) }
            it { expect((removed_atoms - diff_atoms).size).to eq(excess_rels_num) }

            let(:fixed_rels_num) { rels_num(fixed_links) }
            let(:target_rels_num) { rels_num(target_links) }
            it { expect(fixed_rels_num).to eq(target_rels_num - excess_rels_num) }
          end

          it_behaves_like :check_excess do
            let(:target_spec) { dept_activated_dimer }
            let(:excess_atoms) { [] }
            let(:excess_rels_num) { 0 }
          end

          it_behaves_like :check_excess do
            let(:target_spec) { dept_cross_bridge_on_bridges_base }
            let(:excess_atoms) { [cross_bridge_on_bridges_base.atom(:_cl0)] }
            let(:excess_rels_num) { 2 }
          end

          it_behaves_like :check_excess do
            let(:target_spec) { dept_twise_activated_cross_bridge_on_bridges }
            let(:excess_atoms) { [cross_bridge_on_bridges_base.atom(:cl)] }
            let(:excess_rels_num) { 2 }
          end

          it_behaves_like :check_excess do
            let(:target_spec) { dept_cross_bridge_on_dimers_base }
            let(:excess_atoms) { [base_spec.atom(:_crb0), base_spec.atom(:_clb0)] }
            let(:excess_rels_num) { 4 }
          end
        end
      end

    end
  end
end
