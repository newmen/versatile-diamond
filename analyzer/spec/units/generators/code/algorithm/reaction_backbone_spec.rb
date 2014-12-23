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
                let(:target_spec) { subject.source.last }
                let(:atoms) { [target_spec.atom(:ct)] }
              end

              it_behaves_like :check_finite_graph do
                subject { dept_sierpinski_drop }
                let(:target_spec) { cross_bridge_on_bridges_base }
                let(:atoms) do
                  [
                    target_spec.atom(:ctl),
                    target_spec.atom(:cm),
                    target_spec.atom(:ctr)
                  ]
                end
              end
            end

            describe 'in both directions with one relation' do
              subject { dept_dimer_formation }
              let(:ab) { subject.source.first }
              let(:aib) { subject.source.last }
              let(:a1) { ab.atom(:ct) }
              let(:a2) { aib.atom(:ct) }

              it_behaves_like :check_finite_graph do
                let(:target_spec) { ab }
                let(:final_graph) do
                  {
                    [a1] => [[[a2], param_100_front]]
                  }
                end
              end

              it_behaves_like :check_finite_graph do
                let(:target_spec) { aib }
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
              let(:amob) { subject.source.first }
              let(:ad) { subject.source.last }
              let(:am1) { amob.atom(:cr) }
              let(:am2) { amob.atom(:cl) }
              let(:ad1) { ad.atom(:cr) }
              let(:ad2) { ad.atom(:cl) }

              it_behaves_like :check_finite_graph do
                let(:target_spec) { amob }
                let(:final_graph) do
                  {
                    [am1, am2] => [[[ad2, ad1], param_100_cross]]
                  }
                end
              end

              it_behaves_like :check_finite_graph do
                let(:base_specs) { [dept_bridge_base] }
                let(:specific_specs) { [dept_activated_methyl_on_bridge] }
                let(:target_spec) { ad }
                let(:amb) { amob.atom(:cb) }
                let(:amm) { amob.atom(:cm) }
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
              let(:ab) { subject.source.first }
              let(:target_spec) { ab }
              let(:points_list) { [[ab.atom(:ct)]] }
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
              let(:amob) { subject.source.first }
              let(:ad) { subject.source.last }

              it_behaves_like :check_entry_nodes do
                let(:target_spec) { amob }
                let(:points_list) { [[amob.atom(:cr), amob.atom(:cl)]] }
              end

              it_behaves_like :check_entry_nodes do
                let(:base_specs) { [dept_bridge_base] }
                let(:target_spec) { ad }
                let(:points_list) { [[ad.atom(:cl), ad.atom(:cr)]] }
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
              let(:ab) { subject.source.first }
              let(:aib) { subject.source.last }
              let(:target_spec) { ab }
              let(:ordered_graph) do
                [
                  [[ab.atom(:ct)], [[[aib.atom(:ct)], param_100_front]]]
                ]
              end
            end

            describe 'in both directions without explicit relation' do
              subject { dept_intermed_migr_dh_formation }
              let(:ab) { subject.source.first }
              let(:amod) { subject.source.last }

              let(:br) { ab.atom(:cr) }
              let(:bl) { ab.atom(:cl) }
              let(:dr) { amod.atom(:cr) }
              let(:dl) { amod.atom(:cl) }

              it_behaves_like :check_ordered_graph do
                let(:base_specs) { [dept_bridge_base, dept_dimer_base] }
                let(:specific_specs) { [amod] }
                let(:target_spec) { ab }
                let(:dm) { amod.atom(:cm) }
                let(:ordered_graph) do
                  [
                    [[br, bl], [[[dr, dl], param_100_cross]]],
                    [[dr], [[[dm], param_amorph]]],
                    [[dl], []]
                  ]
                end
              end

              it_behaves_like :check_ordered_graph do
                let(:base_specs) { [dept_bridge_base] }
                let(:specific_specs) { [ab] }
                let(:target_spec) { amod }
                let(:bt) { ab.atom(:ct) }
                let(:ordered_graph) do
                  [
                    [[dr, dl], [[[br, bl], param_100_cross]]],
                    [[br], [[[bt], param_110_front]]],
                    [[br, bl], []]
                  ]
                end
              end
            end

            describe 'in both directions with many relation' do
              subject { dept_methyl_incorporation }
              let(:amob) { subject.source.first }
              let(:ad) { subject.source.last }
              let(:am1) { amob.atom(:cr) }
              let(:am2) { amob.atom(:cl) }
              let(:ad1) { ad.atom(:cr) }
              let(:ad2) { ad.atom(:cl) }

              it_behaves_like :check_ordered_graph do
                let(:base_specs) do
                  [dept_bridge_base, dept_methyl_on_bridge_base, dept_dimer_base]
                end
                let(:target_spec) { amob }
                let(:ordered_graph) do
                  [
                    [[am1, am2], [[[ad2, ad1], param_100_cross]]]
                  ]
                end
              end

              it_behaves_like :check_ordered_graph do
                let(:base_specs) { [dept_bridge_base] }
                let(:specific_specs) { [dept_activated_methyl_on_bridge] }
                let(:target_spec) { ad }
                let(:amb) { amob.atom(:cb) }
                let(:amm) { amob.atom(:cm) }
                let(:ordered_graph) do
                  [
                    [[ad2, ad1], [[[am1, am2], param_100_cross]]],
                    [[am1, am2], [[[amb], param_110_front]]],
                    [[amb], [[[amm], param_amorph]]]
                  ]
                end
              end
            end

            describe 'in both directions with many species' do
              subject { dept_methyl_to_gap }
              let(:specific_specs) { [amob, br1] }

              let(:amob) { subject.source.first }
              let(:br1) { subject.source[1] }
              let(:br2) { subject.source[2] }

              let(:amr) { amob.atom(:cr) }
              let(:aml) { amob.atom(:cl) }
              let(:cr1) { br1.atom(:cr) }
              let(:cr2) { br2.atom(:cr) }

              it_behaves_like :check_ordered_graph do
                let(:base_specs) { [dept_bridge_base] }
                let(:target_spec) { amob }
                let(:ordered_graph) do
                  [
                    [[aml, amr], [[[cr2, cr1], param_100_cross]]]
                  ]
                end
              end

              it_behaves_like :check_ordered_graph do
                let(:base_specs) { [dept_bridge_base, dept_methyl_on_bridge_base] }
                let(:target_spec) { br1 }
                let(:amb) { amob.atom(:cb) }
                let(:amm) { amob.atom(:cm) }
                let(:ordered_graph) do
                  [
                    [[cr1], [[[cr2], param_100_front]]],
                    [[cr1, cr2], [[[amr, aml], param_100_cross]]],
                    [[amr, aml], [[[amb], param_110_front]]],
                    [[amb], [[[amm], param_amorph]]]
                  ]
                end
              end
            end

            describe 'in both directions with addit. and without explicit relation' do
              subject { dept_intermed_migr_dmod_formation }
              let(:base_specs) do
                [
                  dept_bridge_base,
                  dept_dimer_base,
                  dept_methyl_on_bridge_base,
                  dept_methyl_on_dimer_base
                ]
              end
              let(:specific_specs) { [amob, adimod, dept_activated_dimer] }
              let(:amob) { subject.source.first }
              let(:adimod) { subject.source.last }

              let(:br) { amob.atom(:cr) }
              let(:bl) { amob.atom(:cl) }
              let(:dr) { adimod.atom(:cr) }
              let(:dl) { adimod.atom(:cl) }

              it_behaves_like :check_ordered_graph do
                let(:target_spec) { amob }
                let(:dm) { adimod.atom(:cm) }
                let(:ordered_graph) do
                  [
                    [[br, bl], [[[dl, dr], param_100_cross]]],
                    [[dr], []]
                  ]
                end
              end

              it_behaves_like :check_ordered_graph do
                let(:target_spec) { adimod }
                let(:bt) { amob.atom(:cb) }
                let(:bm) { amob.atom(:cm) }
                let(:ordered_graph) do
                  [
                    [[dl, dr], [[[br, bl], param_100_cross]]],
                    [[br], [[[bt], param_110_front]]],
                    [[bt], [[[bm], param_amorph]]],
                    [[br, bl], []]
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
