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

          let(:source) { subject.source.reject(&:gas?).reject(&:simple?) }
          let(:reaction) { generator.reaction_class(subject.name) }
          let(:specie) { generator.specie_class(target_spec.name) }
          let(:backbone) { described_class.new(generator, reaction, specie) }

          let(:target_spec) { source.first }

          describe '#final_graph' do
            describe 'without positions' do
              let(:final_graph) do
                { atoms => [] }
              end

              it_behaves_like :check_finite_graph do
                subject { dept_methyl_activation }
                let(:atoms) { [target_spec.atom(:cm)] }
              end

              it_behaves_like :check_finite_graph do
                subject { dept_methyl_desorption }
                let(:atoms) { [target_spec.atom(:cb)] }
              end

              it_behaves_like :check_finite_graph do
                subject { dept_methyl_adsorption }
                let(:atoms) { [target_spec.atom(:ct)] }
              end

              it_behaves_like :check_finite_graph do
                subject { dept_incoherent_dimer_drop }
                let(:atoms) do
                  [
                    target_spec.atom(:cr),
                    target_spec.atom(:cl)
                  ]
                end
              end

              it_behaves_like :check_finite_graph do
                subject { dept_sierpinski_drop }
                let(:atoms) do
                  [
                    target_spec.atom(:ctl),
                    target_spec.atom(:cm),
                    target_spec.atom(:ctr)
                  ]
                end
              end
            end

            describe 'both directions sierpinski formation' do
              subject { dept_sierpinski_formation }
              let(:ab) { source.last }
              let(:amob) { source.first }
              let(:ct) { ab.atom(:ct) }
              let(:cb) { amob.atom(:cb) }
              let(:cm) { amob.atom(:cm) }

              it_behaves_like :check_finite_graph do
                let(:target_spec) { ab }
                let(:final_graph) do
                  {
                    [ct] => [[[cb], param_100_cross]],
                    [cb] => [[[cm], param_amorph]]
                  }
                end
              end

              it_behaves_like :check_finite_graph do
                let(:target_spec) { amob }
                let(:final_graph) do
                  {
                    [cb] => [[[ct], param_100_cross]]
                  }
                end
              end
            end

            describe 'in both directions with one relation' do
              subject { dept_dimer_formation }
              let(:ab) { source.first }
              let(:aib) { source.last }
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
              subject { dept_intermed_migr_dc_formation }
              let(:base_specs) { [dept_bridge_base, dept_methyl_on_bridge_base] }
              let(:ab) { source.first }
              let(:amod) { source.last }
              let(:br) { ab.atom(:cr) }
              let(:dr) { amod.atom(:cr) }

              it_behaves_like :check_finite_graph do
                let(:target_spec) { ab }
                let(:dm) { amod.atom(:cm) }
                let(:final_graph) do
                  {
                    [br] => [[[dr], param_100_cross]],
                    [dr] => [[[dm], param_amorph]]
                  }
                end
              end

              it_behaves_like :check_finite_graph do
                let(:target_spec) { amod }
                let(:bt) { ab.atom(:ct) }
                let(:final_graph) do
                  {
                    [dr] => [[[br], param_100_cross]],
                    [br] => [[[bt], param_110_front]]
                  }
                end
              end
            end

            describe 'in both directions with non position relation' do
              subject { dept_intermed_migr_dh_formation }
              let(:base_specs) { [dept_bridge_base, dept_methyl_on_bridge_base] }
              let(:ab) { source.first }
              let(:amod) { source.last }
              let(:br) { ab.atom(:cr) }
              let(:bl) { ab.atom(:cl) }
              let(:dr) { amod.atom(:cr) }
              let(:dl) { amod.atom(:cl) }

              it_behaves_like :check_finite_graph do
                let(:target_spec) { ab }
                let(:dm) { amod.atom(:cm) }
                let(:final_graph) do
                  {
                    [br, bl] => [[[dr, dl], param_100_cross]],
                    [dr] => [[[dm], param_amorph]]
                  }
                end
              end

              it_behaves_like :check_finite_graph do
                let(:target_spec) { amod }
                let(:bt) { ab.atom(:ct) }
                let(:final_graph) do
                  {
                    [dr, dl] => [[[br, bl], param_100_cross]],
                    [br] => [[[bt], param_110_front]]
                  }
                end
              end
            end

            describe 'in both directions with many relation' do
              subject { dept_methyl_incorporation }
              let(:amob) { source.first }
              let(:ad) { source.last }
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
                let(:specific_specs) { [dept_extra_activated_methyl_on_bridge] }
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

            describe 'two level dimers in all directions' do
              subject { dept_two_dimers_form }
              let(:eamob) { source.first }
              let(:rab) { source[1] }
              let(:aid) { source[2] }
              let(:mr) { eamob.atom(:cr) }
              let(:ml) { eamob.atom(:cl) }
              let(:ba) { rab.atom(:cr) }
              let(:da) { aid.atom(:cl) }

              it_behaves_like :check_finite_graph do
                let(:target_spec) { eamob }
                let(:final_graph) do
                  {
                    [mr, ml] => [[[ba, da], param_100_cross]]
                  }
                end
              end

              describe 'from activated gap' do
                let(:specific_specs) { [dept_extra_activated_methyl_on_bridge] }
                let(:mb) { eamob.atom(:cb) }
                let(:mm) { eamob.atom(:cm) }

                it_behaves_like :check_finite_graph do
                  let(:base_specs) { [dept_bridge_base, dept_methyl_on_bridge_base] }
                  let(:target_spec) { rab }
                  let(:final_graph) do
                    {
                      [ba] => [[[da], param_100_front]],
                      [da, ba] => [[[ml, mr], param_100_cross]],
                      [ml, mr] => [[[mb], param_110_front]],
                      [mb] => [[[mm], param_amorph]]
                    }
                  end
                end

                it_behaves_like :check_finite_graph do
                  let(:base_specs) { [dept_dimer_base, dept_methyl_on_bridge_base] }
                  let(:target_spec) { aid }
                  let(:final_graph) do
                    {
                      [da] => [[[ba], param_100_front]],
                      [da, ba] => [[[ml, mr], param_100_cross]],
                      [ml, mr] => [[[mb], param_110_front]],
                      [mb] => [[[mm], param_amorph]]
                    }
                  end
                end
              end
            end
          end

          describe '#entry_nodes' do
            let(:entry_nodes) { backbone.entry_nodes }

            it_behaves_like :check_entry_nodes do
              subject { dept_methyl_activation }
              let(:points_list) { [[target_spec.atom(:cm)]] }
            end

            it_behaves_like :check_entry_nodes do
              subject { dept_dimer_formation }
              let(:ab) { source.first }
              let(:target_spec) { ab }
              let(:points_list) { [[ab.atom(:ct)]] }
            end

            it_behaves_like :check_entry_nodes do
              subject { dept_incoherent_dimer_drop }
              let(:id) { source.first }
              let(:target_spec) { id }
              let(:points_list) do
                [[
                  id.atom(:cr), id.atom(:cl)
                ]]
              end
            end

            it_behaves_like :check_entry_nodes do
              subject { dept_sierpinski_drop }
              let(:target_spec) { source.first }
              let(:points_list) do
                [[
                  target_spec.atom(:ctl),
                  target_spec.atom(:cm),
                  target_spec.atom(:ctr)
                ]]
              end
            end

            describe 'both directions sierpinski formation' do
              subject { dept_sierpinski_formation }
              let(:ab) { source.last }
              let(:amob) { source.first }

              it_behaves_like :check_entry_nodes do
                let(:target_spec) { ab }
                let(:points_list) { [[ab.atom(:ct)]] }
              end

              it_behaves_like :check_entry_nodes do
                let(:target_spec) { amob }
                let(:points_list) { [[amob.atom(:cb)]] }
              end
            end

            describe 'in both directions without explicit relation' do
              subject { dept_intermed_migr_dc_formation }
              let(:points_list) { [[target_spec.atom(:cr)]] }

              it_behaves_like :check_entry_nodes do
                let(:target_spec) { activated_bridge }
              end

              it_behaves_like :check_entry_nodes do
                let(:target_spec) { activated_methyl_on_dimer }
              end
            end

            describe 'in both directions with no position relation' do
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
              let(:amob) { source.first }
              let(:ad) { source.last }

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

            describe 'two level dimers in all directions' do
              subject { dept_two_dimers_form }
              let(:eamob) { source.first }
              let(:rab) { source[1] }
              let(:aid) { source[2] }

              it_behaves_like :check_entry_nodes do
                let(:target_spec) { eamob }
                let(:points_list) { [[eamob.atom(:cl), eamob.atom(:cr)]] }
              end

              it_behaves_like :check_entry_nodes do
                let(:target_spec) { rab }
                let(:points_list) { [[rab.atom(:cr)]] }
              end

              it_behaves_like :check_entry_nodes do
                let(:target_spec) { aid }
                let(:points_list) { [[aid.atom(:cl)]] }
              end
            end
          end

          describe '#ordered_graph_from' do
            it_behaves_like :check_ordered_graph do
              subject { dept_methyl_activation }
              let(:ordered_graph) do
                [
                  [[target_spec.atom(:cm)], []]
                ]
              end
            end

            it_behaves_like :check_ordered_graph do
              subject { dept_sierpinski_drop }
              let(:atoms) do
                [
                  target_spec.atom(:ctl),
                  target_spec.atom(:cm),
                  target_spec.atom(:ctr)
                ]
              end
              let(:ordered_graph) do
                [
                  [atoms, []]
                ]
              end
            end

            describe 'both directions sierpinski formation' do
              subject { dept_sierpinski_formation }
              let(:ab) { source.last }
              let(:amob) { source.first }
              let(:ct) { ab.atom(:ct) }
              let(:cb) { amob.atom(:cb) }
              let(:cm) { amob.atom(:cm) }

              it_behaves_like :check_ordered_graph do
                let(:target_spec) { ab }
                let(:ordered_graph) do
                  [
                    [[ct], [[[cb], param_100_cross]]],
                    [[cb], [[[cm], param_amorph]]]
                  ]
                end
              end

              it_behaves_like :check_ordered_graph do
                let(:target_spec) { amob }
                let(:ordered_graph) do
                  [
                    [[cb], [[[ct], param_100_cross]]]
                  ]
                end
              end
            end

            it_behaves_like :check_ordered_graph do
              subject { dept_incoherent_dimer_drop }
              let(:ordered_graph) do
                [
                  [[target_spec.atom(:cr), target_spec.atom(:cl)], []]
                ]
              end
            end

            it_behaves_like :check_ordered_graph do
              subject { dept_dimer_formation }
              let(:ab) { source.first }
              let(:aib) { source.last }
              let(:target_spec) { ab }
              let(:ordered_graph) do
                [
                  [[ab.atom(:ct)], [[[aib.atom(:ct)], param_100_front]]]
                ]
              end
            end

            describe 'in both directions without explicit relation' do
              subject { dept_intermed_migr_dc_formation }
              let(:ab) { source.first }
              let(:amod) { source.last }
              let(:br) { ab.atom(:cr) }
              let(:dr) { amod.atom(:cr) }

              it_behaves_like :check_ordered_graph do
                let(:base_specs) { [dept_bridge_base, dept_dimer_base] }
                let(:specific_specs) { [amod] }
                let(:target_spec) { ab }
                let(:dm) { amod.atom(:cm) }
                let(:ordered_graph) do
                  [
                    [[br], [[[dr], param_100_cross]]],
                    [[dr], [[[dm], param_amorph]]]
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
                    [[dr], [[[br], param_100_cross]]],
                    [[br], [[[bt], param_110_front]]]
                  ]
                end
              end
            end

            describe 'in both directions with non position relation' do
              subject { dept_intermed_migr_dh_formation }
              let(:ab) { source.first }
              let(:amod) { source.last }
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
                    [[dr], [[[dm], param_amorph]]]
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
                    [[br], [[[bt], param_110_front]]]
                  ]
                end
              end
            end

            describe 'in both directions with many relation' do
              subject { dept_methyl_incorporation }
              let(:amob) { source.first }
              let(:ad) { source.last }
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

              # There should be directed getting from subject because veiled species
              # will replace original source species after preudo results organization
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
                    [[cr2, cr1], [[[aml, amr], param_100_cross]]],
                    [[aml, amr], [[[amb], param_110_front]]],
                    [[amb], [[[amm], param_amorph]]]
                  ]
                end
              end
            end

            describe 'two level dimers in all directions' do
              subject { dept_two_dimers_form }
              let(:eamob) { source.first }
              let(:rab) { source[1] }
              let(:aid) { source[2] }
              let(:mr) { eamob.atom(:cr) }
              let(:ml) { eamob.atom(:cl) }
              let(:ba) { rab.atom(:cr) }
              let(:da) { aid.atom(:cl) }

              it_behaves_like :check_ordered_graph do
                let(:target_spec) { eamob }
                let(:ordered_graph) do
                  [
                    [[ml, mr], [[[da, ba], param_100_cross]]]
                  ]
                end
              end

              describe 'from activated gap' do
                let(:specific_specs) { [dept_extra_activated_methyl_on_bridge] }
                let(:mb) { eamob.atom(:cb) }
                let(:mm) { eamob.atom(:cm) }

                it_behaves_like :check_ordered_graph do
                  let(:base_specs) { [dept_bridge_base, dept_methyl_on_bridge_base] }
                  let(:target_spec) { rab }
                  let(:ordered_graph) do
                    [
                      [[ba], [[[da], param_100_front]]],
                      [[da, ba], [[[ml, mr], param_100_cross]]],
                      [[ml, mr], [[[mb], param_110_front]]],
                      [[mb], [[[mm], param_amorph]]]
                    ]
                  end
                end

                it_behaves_like :check_ordered_graph do
                  let(:base_specs) { [dept_dimer_base, dept_methyl_on_bridge_base] }
                  let(:target_spec) { aid }
                  let(:ordered_graph) do
                    [
                      [[da], [[[ba], param_100_front]]],
                      [[da, ba], [[[ml, mr], param_100_cross]]],
                      [[ml, mr], [[[mb], param_110_front]]],
                      [[mb], [[[mm], param_amorph]]]
                    ]
                  end
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
              let(:amob) { source.first }
              let(:adimod) { source.last }
              let(:br) { amob.atom(:cr) }
              let(:bl) { amob.atom(:cl) }
              let(:dr) { adimod.atom(:cr) }
              let(:dl) { adimod.atom(:cl) }

              it_behaves_like :check_ordered_graph do
                let(:target_spec) { amob }
                let(:dm) { adimod.atom(:cm) }
                let(:ordered_graph) do
                  [
                    [[bl, br], [[[dr, dl], param_100_cross]]]
                  ]
                end
              end

              it_behaves_like :check_ordered_graph do
                let(:target_spec) { adimod }
                let(:bt) { amob.atom(:cb) }
                let(:bm) { amob.atom(:cm) }
                let(:ordered_graph) do
                  [
                    [[dr, dl], [[[bl, br], param_100_cross]]],
                    [[br], [[[bt], param_110_front]]],
                    [[bt], [[[bm], param_amorph]]]
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
