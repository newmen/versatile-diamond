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
                let(:atoms) { [:cm] }
              end

              it_behaves_like :check_finite_graph do
                subject { dept_methyl_desorption }
                let(:atoms) { [:cb] }
              end

              it_behaves_like :check_finite_graph do
                subject { dept_methyl_adsorption }
                let(:atoms) { [:ct] }
              end

              it_behaves_like :check_finite_graph do
                subject { dept_incoherent_dimer_drop }
                let(:atoms) { [:cr, :cl] }
              end

              it_behaves_like :check_finite_graph do
                subject { dept_sierpinski_drop }
                let(:atoms) { [:ctl, :cm, :ctr] }
              end
            end

            describe 'both directions sierpinski formation' do
              subject { dept_sierpinski_formation }

              it_behaves_like :check_finite_graph do
                let(:target_spec) { source.last }
                let(:final_graph) do
                  {
                    [:ct] => [[[:cb], param_100_cross]],
                    [:cb] => [[[:cm], param_amorph]]
                  }
                end
              end

              it_behaves_like :check_finite_graph do
                let(:target_spec) { source.first }
                let(:final_graph) do
                  {
                    [:cb] => [[[:ct], param_100_cross]]
                  }
                end
              end
            end

            describe 'in both directions with one relation' do
              subject { dept_dimer_formation }

              let(:ab) { :'bridge(ct: *)__ct' }
              let(:aib) { :'bridge(ct: *, ct: i)__ct' }

              it_behaves_like :check_finite_graph do
                let(:target_spec) { source.first }
                let(:final_graph) do
                  {
                    [ab] => [[[aib], param_100_front]]
                  }
                end
              end

              it_behaves_like :check_finite_graph do
                let(:target_spec) { source.last }
                let(:final_graph) do
                  {
                    [aib] => [[[ab], param_100_front]]
                  }
                end
              end
            end

            describe 'in both directions without explicit relation' do
              subject { dept_intermed_migr_dc_formation }
              let(:base_specs) { [dept_bridge_base, dept_methyl_on_bridge_base] }

              let(:br) { :'bridge(ct: *)__cr' }
              let(:modr) { :'methyl_on_dimer(cm: *)__cr' }

              it_behaves_like :check_finite_graph do
                let(:target_spec) { source.first }
                let(:final_graph) do
                  {
                    [br] => [[[modr], param_100_cross]],
                    [modr] => [[[:cm], param_amorph]]
                  }
                end
              end

              it_behaves_like :check_finite_graph do
                let(:target_spec) { source.last }
                let(:final_graph) do
                  {
                    [modr] => [[[br], param_100_cross]],
                    [br] => [[[:ct], param_110_front]]
                  }
                end
              end
            end

            describe 'in both directions with non position relation' do
              subject { dept_intermed_migr_dh_formation }
              let(:base_specs) { [dept_bridge_base, dept_methyl_on_bridge_base] }

              let(:br) { :'bridge(ct: *)__cr' }
              let(:bl) { :'bridge(ct: *)__cl' }
              let(:modr) { :'methyl_on_dimer(cm: *)__cr' }
              let(:modl) { :'methyl_on_dimer(cm: *)__cl' }

              it_behaves_like :check_finite_graph do
                let(:target_spec) { source.first }
                let(:final_graph) do
                  {
                    [br, bl] => [[[modr, modl], param_100_cross]],
                    [modr] => [[[:cm], param_amorph]]
                  }
                end
              end

              it_behaves_like :check_finite_graph do
                let(:target_spec) { source.last }
                let(:final_graph) do
                  {
                    [modr, modl] => [[[br, bl], param_100_cross]],
                    [br] => [[[:ct], param_110_front]]
                  }
                end
              end
            end

            describe 'in both directions with many relation' do
              subject { dept_methyl_incorporation }
              let(:dr) { :'dimer(cr: *)__cr' }
              let(:dl) { :'dimer(cr: *)__cl' }
              let(:mobr) { :'methyl_on_bridge(cm: *)__cr' }
              let(:mobl) { :'methyl_on_bridge(cm: *)__cl' }

              it_behaves_like :check_finite_graph do
                let(:target_spec) { source.first }
                let(:final_graph) do
                  {
                    [mobr, mobl] => [[[dl, dr], param_100_cross]]
                  }
                end
              end

              it_behaves_like :check_finite_graph do
                let(:base_specs) { [dept_bridge_base] }
                let(:specific_specs) { [dept_extra_activated_methyl_on_bridge] }
                let(:target_spec) { source.last }
                let(:final_graph) do
                  {
                    [dl, dr] => [[[mobr, mobl], param_100_cross]],
                    [mobr, mobl] => [[[:cb], param_110_front]],
                    [:cb] => [[[:cm], param_amorph]]
                  }
                end
              end
            end

            describe 'two level dimers in all directions' do
              subject { dept_two_side_dimers_formation }
              let(:dl) { :'dimer(cl: *, cr: i)__cl' }
              let(:br) { :'bridge(cr: *)__cr' }
              let(:mobl) { :'methyl_on_bridge(cm: *, cm: *)__cl' }
              let(:mobr) { :'methyl_on_bridge(cm: *, cm: *)__cr' }

              it_behaves_like :check_finite_graph do
                let(:target_spec) { source.first }
                let(:final_graph) do
                  {
                    [mobr, mobl] => [[[br, dl], param_100_cross]]
                  }
                end
              end

              describe 'from activated gap' do
                let(:specific_specs) { [dept_extra_activated_methyl_on_bridge] }

                it_behaves_like :check_finite_graph do
                  let(:base_specs) { [dept_bridge_base, dept_methyl_on_bridge_base] }
                  let(:target_spec) { source[1] }
                  let(:final_graph) do
                    {
                      [br] => [[[dl], param_100_front]],
                      [dl, br] => [[[mobl, mobr], param_100_cross]],
                      [mobl, mobr] => [[[:cb], param_110_front]],
                      [:cb] => [[[:cm], param_amorph]]
                    }
                  end
                end

                it_behaves_like :check_finite_graph do
                  let(:base_specs) { [dept_dimer_base, dept_methyl_on_bridge_base] }
                  let(:target_spec) { source.last }
                  let(:final_graph) do
                    {
                      [dl] => [[[br], param_100_front]],
                      [dl, br] => [[[mobl, mobr], param_100_cross]],
                      [mobl, mobr] => [[[:cb], param_110_front]],
                      [:cb] => [[[:cm], param_amorph]]
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
              let(:points_list) { [[:cm]] }
            end

            it_behaves_like :check_entry_nodes do
              subject { dept_dimer_formation }
              let(:target_spec) { source.first }
              let(:points_list) { [[:ct]] }
            end

            it_behaves_like :check_entry_nodes do
              subject { dept_incoherent_dimer_drop }
              let(:target_spec) { source.first }
              let(:points_list) { [[:cl, :cr]] }
            end

            it_behaves_like :check_entry_nodes do
              subject { dept_sierpinski_drop }
              let(:target_spec) { source.first }
              let(:points_list) { [[:ctl, :ctr, :cm]] }
            end

            describe 'both directions sierpinski formation' do
              subject { dept_sierpinski_formation }

              it_behaves_like :check_entry_nodes do
                let(:target_spec) { source.last }
                let(:points_list) { [[:ct]] }
              end

              it_behaves_like :check_entry_nodes do
                let(:target_spec) { source.first }
                let(:points_list) { [[:cb]] }
              end
            end

            describe 'in both directions without explicit relation' do
              subject { dept_intermed_migr_dc_formation }
              let(:points_list) { [[:cr]] }

              it_behaves_like :check_entry_nodes do
                let(:target_spec) { activated_bridge }
              end

              it_behaves_like :check_entry_nodes do
                let(:target_spec) { activated_methyl_on_dimer }
              end
            end

            describe 'in both directions with no position relation' do
              subject { dept_intermed_migr_dh_formation }

              it_behaves_like :check_entry_nodes do
                let(:target_spec) { activated_bridge }
                let(:points_list) { [[:cl, :cr]] }
              end

              it_behaves_like :check_entry_nodes do
                let(:target_spec) { activated_methyl_on_dimer }
                let(:points_list) { [[:cr, :cl]] }
              end
            end

            describe 'in both directions with many relation' do
              subject { dept_methyl_incorporation }

              it_behaves_like :check_entry_nodes do
                let(:target_spec) { source.first }
                let(:points_list) { [[:cl, :cr]] }
              end

              it_behaves_like :check_entry_nodes do
                let(:base_specs) { [dept_bridge_base] }
                let(:target_spec) { source.last }
                let(:points_list) { [[:cr, :cl]] }
              end
            end

            describe 'two level dimers in all directions' do
              subject { dept_two_side_dimers_formation }

              it_behaves_like :check_entry_nodes do
                let(:target_spec) { source.first }
                let(:points_list) { [[:cl, :cr]] }
              end

              it_behaves_like :check_entry_nodes do
                let(:target_spec) { source[1] }
                let(:points_list) { [[:cr]] }
              end

              it_behaves_like :check_entry_nodes do
                let(:target_spec) { source.last }
                let(:points_list) { [[:cl]] }
              end
            end
          end

          describe '#ordered_graph_from' do
            it_behaves_like :check_ordered_graph do
              subject { dept_methyl_activation }
              let(:ordered_graph) do
                [
                  [[:cm], []]
                ]
              end
            end

            it_behaves_like :check_ordered_graph do
              subject { dept_sierpinski_drop }
              let(:ordered_graph) do
                [
                  [[:ctl, :ctr, :cm], []]
                ]
              end
            end

            describe 'both directions sierpinski formation' do
              subject { dept_sierpinski_formation }

              it_behaves_like :check_ordered_graph do
                let(:target_spec) { source.last }
                let(:ordered_graph) do
                  [
                    [[:ct], [[[:cb], param_100_cross]]],
                    [[:cb], [[[:cm], param_amorph]]]
                  ]
                end
              end

              it_behaves_like :check_ordered_graph do
                let(:target_spec) { source.first }
                let(:ordered_graph) do
                  [
                    [[:cb], [[[:ct], param_100_cross]]]
                  ]
                end
              end
            end

            it_behaves_like :check_ordered_graph do
              subject { dept_incoherent_dimer_drop }
              let(:ordered_graph) do
                [
                  [[:cl, :cr], []]
                ]
              end
            end

            it_behaves_like :check_ordered_graph do
              subject { dept_dimer_formation }

              let(:ab) { :'bridge(ct: *)__ct' }
              let(:aib) { :'bridge(ct: *, ct: i)__ct' }

              let(:target_spec) { source.first }
              let(:ordered_graph) do
                [
                  [[ab], [[[aib], param_100_front]]]
                ]
              end
            end

            describe 'in both directions without explicit relation' do
              subject { dept_intermed_migr_dc_formation }

              let(:modr) { :'methyl_on_dimer(cm: *)__cr' }
              let(:br) { :'bridge(ct: *)__cr' }

              it_behaves_like :check_ordered_graph do
                let(:base_specs) { [dept_bridge_base, dept_dimer_base] }
                let(:specific_specs) { [source.last] }
                let(:target_spec) { source.first }
                let(:ordered_graph) do
                  [
                    [[br], [[[modr], param_100_cross]]],
                    [[modr], [[[:cm], param_amorph]]]
                  ]
                end
              end

              it_behaves_like :check_ordered_graph do
                let(:base_specs) { [dept_bridge_base] }
                let(:specific_specs) { [source.first] }
                let(:target_spec) { source.last }
                let(:ordered_graph) do
                  [
                    [[modr], [[[br], param_100_cross]]],
                    [[br], [[[:ct], param_110_front]]]
                  ]
                end
              end
            end

            describe 'in both directions with non position relation' do
              subject { dept_intermed_migr_dh_formation }

              let(:modr) { :'methyl_on_dimer(cm: *)__cr' }
              let(:modl) { :'methyl_on_dimer(cm: *)__cl' }
              let(:br) { :'bridge(ct: *)__cr' }
              let(:bl) { :'bridge(ct: *)__cl' }

              it_behaves_like :check_ordered_graph do
                let(:base_specs) { [dept_bridge_base, dept_dimer_base] }
                let(:specific_specs) { [source.last] }
                let(:target_spec) { source.first }
                let(:ordered_graph) do
                  [
                    [[bl, br], [[[modl, modr], param_100_cross]]],
                    [[modr], [[[:cm], param_amorph]]]
                  ]
                end
              end

              it_behaves_like :check_ordered_graph do
                let(:base_specs) { [dept_bridge_base] }
                let(:specific_specs) { [source.first] }
                let(:target_spec) { source.last }
                let(:ordered_graph) do
                  [
                    [[modr, modl], [[[br, bl], param_100_cross]]],
                    [[br], [[[:ct], param_110_front]]]
                  ]
                end
              end
            end

            describe 'in both directions with many relation' do
              subject { dept_methyl_incorporation }

              let(:dr) { :'dimer(cr: *)__cr' }
              let(:dl) { :'dimer(cr: *)__cl' }
              let(:mobr) { :'methyl_on_bridge(cm: *)__cr' }
              let(:mobl) { :'methyl_on_bridge(cm: *)__cl' }

              it_behaves_like :check_ordered_graph do
                let(:base_specs) do
                  [dept_bridge_base, dept_methyl_on_bridge_base, dept_dimer_base]
                end
                let(:target_spec) { source.first }
                let(:ordered_graph) do
                  [
                    [[mobl, mobr], [[[dr, dl], param_100_cross]]]
                  ]
                end
              end

              it_behaves_like :check_ordered_graph do
                let(:base_specs) { [dept_bridge_base] }
                let(:specific_specs) { [dept_activated_methyl_on_bridge] }
                let(:target_spec) { source.last }
                let(:ordered_graph) do
                  [
                    [[dr, dl], [[[mobl, mobr], param_100_cross]]],
                    [[mobl, mobr], [[[:cb], param_110_front]]],
                    [[:cb], [[[:cm], param_amorph]]]
                  ]
                end
              end
            end

            describe 'in both directions with many species' do
              subject { dept_methyl_to_gap }

              # There should be directed getting from subject because veiled species
              # will replace original source species after preudo results organization
              let(:specific_specs) { [subject.source.first, subject.source[1]] }

              let(:br0) { :'bridge(cr: *)__0__cr' }
              let(:br1) { :'bridge(cr: *)__1__cr' }
              let(:mobr) { :'methyl_on_bridge(cm: *, cm: *)__cr' }

              it_behaves_like :check_ordered_graph do
                let(:base_specs) { [dept_bridge_base] }
                let(:target_spec) { subject.source.first }
                let(:ordered_graph) do
                  [
                    [[:cl, mobr], [[[br0, br1], param_100_cross]]]
                  ]
                end
              end

              it_behaves_like :check_ordered_graph do
                let(:base_specs) { [dept_bridge_base, dept_methyl_on_bridge_base] }
                let(:target_spec) { subject.source[1] }
                let(:ordered_graph) do
                  [
                    [[br0], [[[br1], param_100_front]]],
                    [[br1, br0], [[[:cl, mobr], param_100_cross]]],
                    [[:cl, mobr], [[[:cb], param_110_front]]],
                    [[:cb], [[[:cm], param_amorph]]]
                  ]
                end
              end
            end

            describe 'two level dimers in all directions' do
              subject { dept_two_side_dimers_formation }

              let(:dl) { :'dimer(cl: *, cr: i)__cl' }
              let(:br) { :'bridge(cr: *)__cr' }
              let(:mobl) { :'methyl_on_bridge(cm: *, cm: *)__cl' }
              let(:mobr) { :'methyl_on_bridge(cm: *, cm: *)__cr' }

              it_behaves_like :check_ordered_graph do
                let(:target_spec) { source.first }
                let(:ordered_graph) do
                  [
                    [[mobl, mobr], [[[dl, br], param_100_cross]]]
                  ]
                end
              end

              describe 'from activated gap' do
                let(:specific_specs) { [dept_extra_activated_methyl_on_bridge] }

                it_behaves_like :check_ordered_graph do
                  let(:base_specs) { [dept_bridge_base, dept_methyl_on_bridge_base] }
                  let(:target_spec) { source[1] }
                  let(:ordered_graph) do
                    [
                      [[br], [[[dl], param_100_front]]],
                      [[dl, br], [[[mobl, mobr], param_100_cross]]],
                      [[mobl, mobr], [[[:cb], param_110_front]]],
                      [[:cb], [[[:cm], param_amorph]]]
                    ]
                  end
                end

                it_behaves_like :check_ordered_graph do
                  let(:base_specs) { [dept_dimer_base, dept_methyl_on_bridge_base] }
                  let(:target_spec) { source.last }
                  let(:ordered_graph) do
                    [
                      [[dl], [[[br], param_100_front]]],
                      [[dl, br], [[[mobl, mobr], param_100_cross]]],
                      [[mobl, mobr], [[[:cb], param_110_front]]],
                      [[:cb], [[[:cm], param_amorph]]]
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
              let(:specific_specs) { source + [dept_activated_dimer] }

              let(:mobl) { :'methyl_on_bridge(cm: *)__cl' }
              let(:mobr) { :'methyl_on_bridge(cm: *)__cr' }
              let(:modl) { :'methyl_on_dimer(cl: *)__cl' }
              let(:modr) { :'methyl_on_dimer(cl: *)__cr' }

              it_behaves_like :check_ordered_graph do
                let(:target_spec) { source.first }
                let(:ordered_graph) do
                  [
                    [[mobl, mobr], [[[modr, modl], param_100_cross]]]
                  ]
                end
              end

              it_behaves_like :check_ordered_graph do
                let(:target_spec) { source.last }
                let(:ordered_graph) do
                  [
                    [[modr, modl], [[[mobl, mobr], param_100_cross]]],
                    [[mobr], [[[:cb], param_110_front]]],
                    [[:cb], [[[:cm], param_amorph]]]
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
