require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        describe ReactionBackbone, type: :algorithm do
          let(:base_specs) { [] }
          let(:specific_specs) { [] }
          let(:generator) do
            stub_generator(
              base_specs: base_specs,
              specific_specs: specific_specs,
              typical_reactions: [subject])
          end

          let(:reaction) { generator.reaction_class(subject.name) }
          let(:specie) { generator.specie_class(target_spec.name) }
          let(:backbone) { described_class.new(generator, reaction, specie) }

          describe '#final_graph' do
            describe 'without positions' do
              let(:final_graph) do
                { atoms => [] }
              end

              it_behaves_like :check_finite_graph do
                subject { dept_methyl_activation }
                let(:target_spec) { methyl_on_bridge_base }
                let(:atoms) { [target_spec.atom(:cm)] }
              end

              it_behaves_like :check_finite_graph do
                subject { dept_methyl_desorption }
                let(:target_spec) { incoherent_methyl_on_bridge }
                let(:atoms) { [target_spec.atom(:cb)] }
              end

              it_behaves_like :check_finite_graph do
                subject { dept_methyl_adsorption }
                let(:target_spec) { activated_bridge }
                let(:atoms) { [target_spec.atom(:ct)] }
              end

              it_behaves_like :check_finite_graph do
                subject { dept_sierpinski_drop }
                let(:target_spec) { cross_bridge_on_bridges_base }
                let(:atoms) do
                  [
                    target_spec.atom(:ctl),
                    target_spec.atom(:ctr),
                    target_spec.atom(:cm)
                  ]
                end
              end
            end

            describe 'in both directions with one relation' do
              subject { dept_dimer_formation }
              let(:a1) { activated_bridge.atom(:ct) }
              let(:a2) { activated_incoherent_bridge.atom(:ct) }

              it_behaves_like :check_finite_graph do
                let(:target_spec) { activated_bridge }
                let(:final_graph) do
                  {
                    [a1] => [[[a2], param_100_front]]
                  }
                end
              end

              it_behaves_like :check_finite_graph do
                let(:target_spec) { activated_incoherent_bridge }
                let(:final_graph) do
                  {
                    [a2] => [[[a1], param_100_front]]
                  }
                end
              end
            end

            describe 'in both directions without explicit relation' do
              subject { dept_intermed_migr_dh_formation }
              let(:ab) { activated_bridge.atom(:cr) }
              let(:ob) { activated_bridge.atom(:cl) }
              let(:ad) { activated_methyl_on_dimer.atom(:cr) }
              let(:od) { activated_methyl_on_dimer.atom(:cl) }

              it_behaves_like :check_finite_graph do
                let(:target_spec) { activated_bridge }
                let(:final_graph) do
                  {
                    [ab, ob] => [[[ad, od], param_100_cross]]
                  }
                end
              end

              it_behaves_like :check_finite_graph do
                let(:target_spec) { activated_methyl_on_dimer }
                let(:final_graph) do
                  {
                    [ad, od] => [[[ab, ob], param_100_cross]]
                  }
                end
              end
            end

            describe 'in both directions with many relation' do
              subject { dept_methyl_incorporation }
              let(:am1) { activated_methyl_on_bridge.atom(:cr) }
              let(:am2) { activated_methyl_on_bridge.atom(:cl) }
              let(:ad1) { activated_dimer.atom(:cr) }
              let(:ad2) { activated_dimer.atom(:cl) }

              it_behaves_like :check_finite_graph do
                let(:target_spec) { activated_methyl_on_bridge }
                let(:final_graph) do
                  {
                    [am1, am2] => [[[ad2, ad1], param_100_cross]]
                  }
                end
              end

              it_behaves_like :check_finite_graph do
                let(:base_specs) { [dept_bridge_base] }
                let(:specific_specs) { [dept_activated_methyl_on_bridge] }
                let(:target_spec) { activated_dimer }
                let(:amb) { activated_methyl_on_bridge.atom(:cb) }
                let(:amm) { activated_methyl_on_bridge.atom(:cm) }
                let(:final_graph) do
                  {
                    [ad2, ad1] => [[[am1, am2], param_100_cross]],
                    [am1, am2] => [[[amb], param_110_front]],
                    [amb] => [[[amm], param_amorph]]
                  }
                end
              end
            end
          end

          describe '#entry_nodes' do
            let(:entry_nodes) { backbone.entry_nodes }

            it_behaves_like :check_entry_nodes do
              subject { dept_methyl_activation }
              let(:target_spec) { methyl_on_bridge_base }
              let(:points_list) { [[target_spec.atom(:cm)]] }
            end

            it_behaves_like :check_entry_nodes do
              subject { dept_dimer_formation }
              let(:target_spec) { activated_bridge }
              let(:points_list) { [[activated_bridge.atom(:ct)]] }
            end

            describe 'in both directions without explicit relation' do
              subject { dept_intermed_migr_dh_formation }
              let(:points_list) { [[target_spec.atom(:cr), target_spec.atom(:cl)]] }

              it_behaves_like :check_entry_nodes do
                let(:target_spec) { activated_bridge }
              end

              it_behaves_like :check_entry_nodes do
                let(:target_spec) { activated_methyl_on_dimer }
              end
            end

            describe 'in both directions with many relation' do
              subject { dept_methyl_incorporation }

              it_behaves_like :check_entry_nodes do
                let(:target_spec) { activated_methyl_on_bridge }
                let(:am1) { activated_methyl_on_bridge.atom(:cr) }
                let(:am2) { activated_methyl_on_bridge.atom(:cl) }
                let(:points_list) { [[am1, am2]] }
              end

              it_behaves_like :check_entry_nodes do
                let(:base_specs) { [dept_bridge_base] }
                let(:target_spec) { activated_dimer }
                let(:ad1) { activated_dimer.atom(:cr) }
                let(:ad2) { activated_dimer.atom(:cl) }
                let(:points_list) { [[ad2, ad1]] }
              end
            end
          end

          describe '#ordered_graph_from' do
            it_behaves_like :check_ordered_graph do
              subject { dept_methyl_activation }
              let(:target_spec) { methyl_on_bridge_base }
              let(:ordered_graph) do
                [
                  [[target_spec.atom(:cm)], []]
                ]
              end
            end

            it_behaves_like :check_ordered_graph do
              subject { dept_dimer_formation }
              let(:target_spec) { activated_bridge }
              let(:a1) { activated_bridge.atom(:ct) }
              let(:a2) { activated_incoherent_bridge.atom(:ct) }
              let(:ordered_graph) do
                [
                  [[a1], [[[a2], param_100_front]]]
                ]
              end
            end

            describe 'in both directions without explicit relation' do
              subject { dept_intermed_migr_dh_formation }
              let(:br) { activated_bridge.atom(:cr) }
              let(:bl) { activated_bridge.atom(:cl) }
              let(:dr) { activated_methyl_on_dimer.atom(:cr) }
              let(:dl) { activated_methyl_on_dimer.atom(:cl) }

              it_behaves_like :check_ordered_graph do
                let(:base_specs) { [dept_bridge_base, dept_dimer_base] }
                let(:specific_specs) { [dept_activated_methyl_on_dimer] }
                let(:target_spec) { activated_bridge }
                let(:dm) { activated_methyl_on_dimer.atom(:cm) }
                let(:ordered_graph) do
                  [
                    [[br, bl], [[[dr, dl], param_100_cross]]],
                    [[dr], [[[dm], param_amorph]]]
                  ]
                end
              end

              it_behaves_like :check_ordered_graph do
                let(:base_specs) { [dept_bridge_base] }
                let(:specific_specs) { [dept_activated_bridge] }
                let(:target_spec) { activated_methyl_on_dimer }
                let(:bt) { activated_bridge.atom(:ct) }
                let(:ordered_graph) do
                  [
                    [[dr, dl], [[[br, bl], param_100_cross]]],
                    [[br], [[[bt], param_110_front]]]
                  ]
                end
              end
            end

            describe 'in both directions with many relation' do
              subject { dept_methyl_incorporation }
              let(:am1) { activated_methyl_on_bridge.atom(:cr) }
              let(:am2) { activated_methyl_on_bridge.atom(:cl) }
              let(:ad1) { activated_dimer.atom(:cr) }
              let(:ad2) { activated_dimer.atom(:cl) }

              it_behaves_like :check_ordered_graph do
                let(:base_specs) do
                  [dept_bridge_base, dept_methyl_on_bridge_base, dept_dimer_base]
                end
                let(:target_spec) { activated_methyl_on_bridge }
                let(:ordered_graph) do
                  [
                    [[am1, am2], [[[ad2, ad1], param_100_cross]]]
                  ]
                end
              end

              it_behaves_like :check_ordered_graph do
                let(:base_specs) { [dept_bridge_base] }
                let(:specific_specs) { [dept_activated_methyl_on_bridge] }
                let(:target_spec) { activated_dimer }
                let(:amb) { activated_methyl_on_bridge.atom(:cb) }
                let(:amm) { activated_methyl_on_bridge.atom(:cm) }
                let(:ordered_graph) do
                  [
                    [[ad2, ad1], [[[am1, am2], param_100_cross]]],
                    [[am1, am2], [[[amb], param_110_front]]],
                    [[amb], [[[amm], param_amorph]]]
                  ]
                end
              end
            end
          end
        end

      end
    end
  end
end
