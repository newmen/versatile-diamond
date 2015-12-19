require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        describe SpecieGroupedNodes, type: :algorithm do
          def node_to_vertex(node)
            node.atom
          end

          let(:base_specs) { [] }
          let(:specific_specs) { [] }
          let(:generator) do
            stub_generator(base_specs: base_specs, specific_specs: specific_specs)
          end

          let(:specie) { generator.specie_class(subject.name) }
          let(:grouped_nodes) { described_class.new(generator, specie) }

          let(:big_links_method) { :original_links }

          Support::RoleChecker::ANCHOR_KEYNAMES.each do |keyname|
            let(keyname) { subject.spec.atom(keyname) }
          end

          it_behaves_like :check_grouped_nodes_graph do
            subject { dept_bridge_base }
            let(:base_specs) { [subject] }
            let(:flatten_face_grouped_atoms) { [[ct], [cr, cl]] }
            let(:nodes_list) do
              [
                [Instances::NoneSpecie, ct],
                [Instances::NoneSpecie, cr],
                [Instances::NoneSpecie, cl]
              ]
            end
            let(:grouped_graph) do
              {
                [ct] => [[[cl, cr], param_110_cross]],
                [cr] => [[[ct], param_110_front]],
                [cl] => [[[ct], param_110_front]]
              }
            end
          end

          describe 'like methyl on bridge' do
            let(:flatten_face_grouped_atoms) { [[cb], [cm]] }
            let(:nodes_list) do
              [
                [Instances::NoneSpecie, cm],
                [Instances::UniqueParent, cb]
              ]
            end
            let(:grouped_graph) do
              {
                [cm] => [[[cb], param_amorph]],
                [cb] => [[[cm], param_amorph]]
              }
            end

            it_behaves_like :check_grouped_nodes_graph do
              subject { dept_methyl_on_bridge_base }
              let(:base_specs) { [dept_bridge_base, subject] }
            end

            it_behaves_like :check_grouped_nodes_graph do
              subject { dept_high_bridge_base }
              let(:base_specs) { [dept_bridge_base, subject] }
            end
          end

          it_behaves_like :check_grouped_nodes_graph do
            subject { dept_vinyl_on_bridge_base }
            let(:base_specs) { [dept_bridge_base, subject] }
            let(:flatten_face_grouped_atoms) { [[cb], [c1], [c2]] }
            let(:nodes_list) do
              [
                [Instances::NoneSpecie, c1],
                [Instances::NoneSpecie, c2],
                [Instances::UniqueParent, cb]
              ]
            end
            let(:grouped_graph) do
              {
                [cb] => [[[c1], param_amorph]],
                [c1] => [[[cb], param_amorph], [[c2], param_amorph]],
                [c2] => [[[c1], param_amorph]]
              }
            end
          end

          it_behaves_like :check_grouped_nodes_graph do
            subject { dept_dimer_base }
            let(:base_specs) { [dept_bridge_base, subject] }
            let(:flatten_face_grouped_atoms) { [[cr, cl]] }
            let(:nodes_list) do
              [
                [Instances::UniqueParent, cr],
                [Instances::UniqueParent, cl]
              ]
            end
            let(:grouped_graph) do
              {
                [cr] => [[[cl], param_100_front]],
                [cl] => [[[cr], param_100_front]]
              }
            end
          end

          it_behaves_like :check_grouped_nodes_graph do
            subject { dept_two_methyls_on_dimer_base }
            let(:base_specs) { [dept_dimer_base, subject] }
            let(:flatten_face_grouped_atoms) { [[cr, cl], [c1], [c2]] }
            let(:nodes_list) do
              [
                [Instances::NoneSpecie, c1],
                [Instances::NoneSpecie, c2],
                [Instances::UniqueParent, cr],
                [Instances::UniqueParent, cl]
              ]
            end
            let(:grouped_graph) do
              {
                [c1] => [[[cr], param_amorph]],
                [c2] => [[[cl], param_amorph]],
                [cr] => [[[c1], param_amorph]],
                [cl] => [[[c2], param_amorph]]
              }
            end
          end

          it_behaves_like :check_grouped_nodes_graph do
            subject { dept_activated_methyl_on_incoherent_bridge }
            let(:base_specs) { [dept_methyl_on_bridge_base] }
            let(:specific_specs) { [subject] }
            let(:flatten_face_grouped_atoms) { [[cb, cm]] }
            let(:nodes_list) do
              [
                [Instances::UniqueParent, cm],
                [Instances::UniqueParent, cb]
              ]
            end
            let(:grouped_graph) do
              {
                [cb, cm] => [],
              }
            end
          end

          it_behaves_like :check_grouped_nodes_graph do
            subject { dept_methyl_on_dimer_base }
            let(:base_specs) do
              [dept_bridge_base, dept_methyl_on_bridge_base, subject]
            end
            let(:flatten_face_grouped_atoms) { [[cr, cl]] }
            let(:nodes_list) do
              [
                [Instances::UniqueParent, cr],
                [Instances::UniqueParent, cl]
              ]
            end
            let(:grouped_graph) do
              {
                [cr] => [[[cl], param_100_front]],
                [cl] => [[[cr], param_100_front]]
              }
            end
          end

          it_behaves_like :check_grouped_nodes_graph do
            subject { dept_three_bridges_base }
            let(:base_specs) { [dept_bridge_base, subject] }
            let(:flatten_face_grouped_atoms) { [[ct, cc]] }
            let(:nodes_list) do
              [
                [Instances::SpeciesScope, ct],
                [Instances::SpeciesScope, cc]
              ]
            end
            let(:grouped_graph) do
              {
                [ct] => [],
                [cc] => []
              }
            end
          end

          it_behaves_like :check_grouped_nodes_graph do
            subject { dept_right_hydrogenated_bridge }
            let(:base_specs) { [dept_bridge_base] }
            let(:specific_specs) { [subject] }
            let(:flatten_face_grouped_atoms) { [[cr]] }
            let(:nodes_list) do
              [
                [Instances::UniqueParent, cr]
              ]
            end
            let(:grouped_graph) do
              {
                [cr] => []
              }
            end
          end

          it_behaves_like :check_grouped_nodes_graph do
            subject { dept_lower_methyl_on_half_extended_bridge_base }
            let(:base_specs) do
              [dept_bridge_base, dept_methyl_on_right_bridge_base, subject]
            end
            let(:flatten_face_grouped_atoms) { [[cr], [cbr]] }
            let(:nodes_list) do
              [
                [Instances::UniqueParent, cr],
                [Instances::UniqueParent, cbr]
              ]
            end
            let(:grouped_graph) do
              {
                [cr] => [[[cbr], param_110_cross]],
                [cbr] => [[[cr], param_110_front]]
              }
            end
          end

          describe 'different dept_cross_bridge_on_bridges_base' do
            subject { dept_cross_bridge_on_bridges_base }
            let(:flatten_face_grouped_atoms) { [[ctl, ctr], [cm]] }

            it_behaves_like :check_grouped_nodes_graph do
              let(:base_specs) { [dept_bridge_base, subject] }
              let(:nodes_list) do
                [
                  [Instances::NoneSpecie, cm],
                  [Instances::UniqueParent, ctr],
                  [Instances::UniqueParent, ctl]
                ]
              end
              let(:grouped_graph) do
                {
                  [cm] => [[[ctr, ctl], param_amorph]],
                  [ctr] => [[[ctl], param_100_cross], [[cm], param_amorph]],
                  [ctl] => [[[ctr], param_100_cross], [[cm], param_amorph]]
                }
              end
            end

            it_behaves_like :check_grouped_nodes_graph do
              let(:base_specs) do
                [dept_bridge_base, dept_methyl_on_bridge_base, subject]
              end
              let(:nodes_list) do
                [
                  [Instances::SpeciesScope, cm],
                  [Instances::UniqueParent, ctr],
                  [Instances::UniqueParent, ctl]
                ]
              end
              let(:grouped_graph) do
                {
                  [cm] => [],
                  [ctr] => [[[ctl], param_100_cross]],
                  [ctl] => [[[ctr], param_100_cross]]
                }
              end
            end
          end

          describe 'different dept_cross_bridge_on_dimers_base' do
            subject { dept_cross_bridge_on_dimers_base }
            let(:flatten_face_grouped_atoms) { [[ctr, csr], [ctl, csl], [cm]] }

            it_behaves_like :check_grouped_nodes_graph do
              let(:base_specs) { [dept_dimer_base, subject] }
              let(:nodes_list) do
                [
                  [Instances::NoneSpecie, cm],
                  [Instances::UniqueParent, ctr],
                  [Instances::UniqueParent, csr],
                  [Instances::UniqueParent, ctl],
                  [Instances::UniqueParent, csl]
                ]
              end
              let(:grouped_graph) do
                {
                  [cm] => [[[ctr, ctl], param_amorph]],
                  [ctr] => [[[cm], param_amorph]],
                  [ctl] => [[[cm], param_amorph]],
                  [csr, ctr] => [[[csl, ctl], param_100_cross]],
                  [csl, ctl] => [[[csr, ctr], param_100_cross]]
                }
              end
            end

            it_behaves_like :check_grouped_nodes_graph do
              let(:base_specs) do
                [dept_dimer_base, dept_methyl_on_dimer_base, subject]
              end
              let(:nodes_list) do
                [
                  [Instances::SpeciesScope, cm],
                  [Instances::UniqueParent, ctr],
                  [Instances::UniqueParent, csr],
                  [Instances::UniqueParent, ctl],
                  [Instances::UniqueParent, csl]
                ]
              end
              let(:grouped_graph) do
                {
                  [cm] => [],
                  [csr, ctr] => [[[csl, ctl], param_100_cross]],
                  [csl, ctl] => [[[csr, ctr], param_100_cross]]
                }
              end
            end
          end

          describe 'intermediate specie of migration down process' do
            let(:base_specs) do
              [
                dept_bridge_base,
                dept_methyl_on_bridge_base,
                dept_methyl_on_dimer_base,
                subject
              ]
            end

            it_behaves_like :check_grouped_nodes_graph do
              subject { dept_intermed_migr_down_common_base }
              let(:flatten_face_grouped_atoms) { [[cbr, cdr], [cm]] }
              let(:nodes_list) do
                [
                  [Instances::UniqueParent, cm],
                  [Instances::UniqueParent, cbr],
                  [Instances::UniqueParent, cdr],
                ]
              end
              let(:grouped_graph) do
                {
                  [cm] => [[[cdr], param_amorph]],
                  [cdr] => [[[cbr], param_100_cross], [[cm], param_amorph]],
                  [cbr] => [[[cdr], param_100_cross]]
                }
              end
            end

            describe 'both lower atoms are related' do
              let(:flatten_face_grouped_atoms) { [[cm, cbr, cbl], [cdr, cdl]] }
              let(:nodes_list) do
                [
                  [Instances::UniqueParent, cm],
                  [Instances::UniqueParent, cbr],
                  [Instances::UniqueParent, cbl],
                  [Instances::UniqueParent, cdr],
                  [Instances::UniqueParent, cdl]
                ]
              end
              let(:grouped_graph) do
                {
                  [cm] => [[[cdr], param_amorph]],
                  [cdr] => [[[cm], param_amorph]],
                  [cdl, cdr] => [[[cbl, cbr], param_100_cross]],
                  [cbr, cbl] => [[[cdr, cdl], param_100_cross]]
                }
              end

              it_behaves_like :check_grouped_nodes_graph do
                subject { dept_intermed_migr_down_half_base }
              end

              it_behaves_like :check_grouped_nodes_graph do
                subject { dept_intermed_migr_down_full_base }
              end
            end
          end
        end

      end
    end
  end
end
