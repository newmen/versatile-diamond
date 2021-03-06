require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe Essence, use: :engine_generator do
        let(:base_specs) { [] }
        let(:specific_specs) { [] }
        let(:typical_reactions) { [] }
        let(:generator) do
          stub_generator(
            base_specs: base_specs,
            specific_specs: specific_specs,
            typical_reactions: typical_reactions)
        end

        let(:specie) { generator.specie_class(subject.name) }
        let(:essence) { specie.essence }

        describe '#cut_links' do
          shared_examples_for :check_cut_links do
            let(:kn_graph) do
              essence.cut_links.each_with_object({}) do |(atom, rels), acc|
                acc[subject.spec.keyname(atom)] =
                  rels.map { |a, r| [subject.spec.keyname(a), r] }
              end
            end

            # each method should not change the state of essence
            it 'all public methods' do
              expect(kn_graph).to match_graph(cut_links)
            end
          end

          it_behaves_like :check_cut_links do
            subject { dept_bridge_base }
            let(:base_specs) { [subject] }
            let(:cut_links) do
              {
                :ct => [[:cl, bond_110_cross], [:cr, bond_110_cross]],
                :cr => [[:ct, bond_110_front]],
                :cl => [[:ct, bond_110_front]]
              }
            end
          end

          describe 'like methyl on bridge' do
            let(:cut_links) do
              {
                :cm => [[:cb, free_bond]],
                :cb => [[:cm, free_bond]]
              }
            end

            it_behaves_like :check_cut_links do
              subject { dept_methyl_on_bridge_base }
              let(:base_specs) { [dept_bridge_base, subject] }
            end

            it_behaves_like :check_cut_links do
              subject { dept_high_bridge_base }
              let(:base_specs) { [dept_bridge_base, subject] }
            end
          end

          it_behaves_like :check_cut_links do
            subject { dept_vinyl_on_bridge_base }
            let(:base_specs) { [dept_bridge_base, subject] }
            let(:cut_links) do
              {
                :cb => [[:c1, free_bond]],
                :c1 => [[:cb, free_bond], [:c2, free_bond]],
                :c2 => [[:c1, free_bond]]
              }
            end
          end

          it_behaves_like :check_cut_links do
            subject { dept_very_high_bridge_base }
            let(:base_specs) { [dept_bridge_base, dept_high_bridge_base, subject] }
            let(:cut_links) do
              {
                :c1 => [[:c2, free_bond]],
                :c2 => [[:c1, free_bond]]
              }
            end
          end

          it_behaves_like :check_cut_links do
            before { subject.replace_base_spec(dept_high_bridge_base) }
            subject { dept_incoherent_very_high_bridge }
            let(:base_specs) do
              [dept_bridge_base, dept_high_bridge_base, dept_vinyl_on_bridge_base]
            end
            let(:specific_specs) { [subject] }
            let(:cut_links) do
              {
                :cm => [[:c2, free_bond]],
                :c2 => [[:cm, free_bond]]
              }
            end
          end

          it_behaves_like :check_cut_links do
            subject { dept_dimer_base }
            let(:base_specs) { [dept_bridge_base, subject] }
            let(:cut_links) do
              {
                :cr => [[:cl, bond_100_front]],
                :cl => [[:cr, bond_100_front]]
              }
            end
          end

          it_behaves_like :check_cut_links do
            subject { dept_extended_bridge_base }
            let(:base_specs) { [dept_bridge_base, subject] }
            let(:cut_links) do
              {
                :cl => [],
                :cr => []
              }
            end
          end

          describe 'different extended dimer' do
            subject { dept_extended_dimer_base }

            it_behaves_like :check_cut_links do
              let(:base_specs) { [dept_bridge_base, dept_dimer_base, subject] }
              let(:cut_links) do
                {
                  :_cr0 => [],
                  :_cr1 => [],
                  :clb => [],
                  :crb => []
                }
              end
            end

            it_behaves_like :check_cut_links do
              let(:base_specs) do
                [dept_bridge_base, dept_dimer_base, dept_extended_bridge_base, subject]
              end
              let(:cut_links) do
                {
                  :cr => [[:cl, bond_100_front]],
                  :cl => [[:cr, bond_100_front]]
                }
              end
            end
          end

          it_behaves_like :check_cut_links do
            subject { dept_activated_methyl_on_dimer }
            let(:base_specs) { [dept_bridge_base, dept_methyl_on_dimer_base] }
            let(:specific_specs) { [subject] }
            let(:cut_links) do
              {
                :cm => []
              }
            end
          end

          describe 'different two methyls on dimer' do
            subject { dept_two_methyls_on_dimer_base }

            it_behaves_like :check_cut_links do
              let(:base_specs) { [dept_dimer_base, subject] }
              let(:cut_links) do
                {
                  :c1 => [[:cr, free_bond]],
                  :c2 => [[:cl, free_bond]],
                  :cr => [[:c1, free_bond]],
                  :cl => [[:c2, free_bond]]
                }
              end
            end

            it_behaves_like :check_cut_links do
              let(:base_specs) do
                [dept_bridge_base, dept_dimer_base, dept_methyl_on_dimer_base, subject]
              end
              let(:typical_reactions) do
                [
                  dept_hydrogen_abs_from_gap,
                  dept_incoherent_dimer_drop,
                  dept_intermed_migr_dh_drop
                ]
              end
              let(:cut_links) do
                {
                  :cl => [[:c2, free_bond]],
                  :c2 => [[:cl, free_bond]]
                }
              end
            end
          end

          it_behaves_like :check_cut_links do
            subject { dept_activated_methyl_on_incoherent_bridge }
            let(:base_specs) { [dept_methyl_on_bridge_base] }
            let(:specific_specs) { [subject] }
            let(:cut_links) do
              {
                :cb => [],
                :cm => []
              }
            end
          end

          describe 'different methyl on dimer' do
            subject { dept_methyl_on_dimer_base }
            let(:cut_links) do
              {
                :cr => [[:cl, bond_100_front]],
                :cl => [[:cr, bond_100_front]]
              }
            end

            it_behaves_like :check_cut_links do
              let(:base_specs) do
                [dept_bridge_base, dept_methyl_on_bridge_base, subject]
              end
            end

            it_behaves_like :check_cut_links do
              let(:base_specs) do
                [
                  dept_bridge_base,
                  dept_methyl_on_bridge_base,
                  dept_cross_bridge_on_dimers_base,
                  subject
                ]
              end
            end
          end

          describe 'different bases for vinyl on dimer' do
            subject { dept_vinyl_on_dimer_base }
            let(:cut_links) do
              {
                :cr => [[:cl, bond_100_front]],
                :cl => [[:cr, bond_100_front]]
              }
            end

            it_behaves_like :check_cut_links do
              let(:base_specs) do
                [dept_bridge_base, dept_vinyl_on_bridge_base, subject]
              end
            end

            it_behaves_like :check_cut_links do
              let(:base_specs) do
                [
                  dept_bridge_base,
                  dept_methyl_on_bridge_base,
                  dept_vinyl_on_bridge_base,
                  subject
                ]
              end
            end
          end

          it_behaves_like :check_cut_links do
            subject { dept_three_bridges_base }
            let(:base_specs) { [dept_bridge_base, subject] }
            let(:cut_links) do
              {
                :ct => [],
                :cc => []
              }
            end
          end

          it_behaves_like :check_cut_links do
            subject { dept_bridge_with_dimer_base }
            let(:base_specs) { [dept_bridge_base, dept_dimer_base, subject] }
            let(:cut_links) do
              {
                :ct => [],
                :cr => []
              }
            end
          end

          it_behaves_like :check_cut_links do
            subject { dept_right_hydrogenated_bridge }
            let(:base_specs) { [dept_bridge_base] }
            let(:specific_specs) { [subject] }
            let(:cut_links) do
              {
                :cr => []
              }
            end
          end

          it_behaves_like :check_cut_links do
            subject { dept_bottom_activated_incoherent_bridge }
            let(:base_specs) { [dept_bridge_base] }
            let(:specific_specs) { [dept_right_activated_bridge, subject] }
            let(:typical_reactions) { [dept_methyl_to_gap] }
            let(:cut_links) do
              {
                :cr => []
              }
            end
          end

          describe 'different lower methyl on half extended bridge' do
            subject { dept_lower_methyl_on_half_extended_bridge_base }

            it_behaves_like :check_cut_links do
              let(:base_specs) { [dept_bridge_base, subject] }
              let(:cut_links) do
                {
                  :cr => [],
                  :cbr => [[:cm, free_bond]],
                  :cm => [[:cbr, free_bond]]
                }
              end
            end

            it_behaves_like :check_cut_links do
              let(:base_specs) do
                [dept_bridge_base, dept_methyl_on_right_bridge_base, subject]
              end
              let(:cut_links) do
                {
                  :cr => [[:cbr, bond_110_cross]],
                  :cbr => [[:cr, bond_110_front]]
                }
              end
            end
          end

          describe 'different cross bridge on bridges' do
            subject { dept_cross_bridge_on_bridges_base }

            it_behaves_like :check_cut_links do
              let(:base_specs) { [dept_bridge_base, subject] }
              let(:cut_links) do
                {
                  :cm => [[:ctr, free_bond], [:ctl, free_bond]],
                  :ctr => [[:ctl, position_100_cross], [:cm, free_bond]],
                  :ctl => [[:ctr, position_100_cross], [:cm, free_bond]],
                }
              end
            end

            it_behaves_like :check_cut_links do
              let(:base_specs) do
                [dept_bridge_base, dept_methyl_on_bridge_base, subject]
              end
              let(:cut_links) do
                {
                  :cm => [],
                  :ctr => [[:ctl, position_100_cross]],
                  :ctl => [[:ctr, position_100_cross]],
                }
              end
            end
          end

          describe 'different cross bridge on dimers' do
            subject { dept_cross_bridge_on_dimers_base }

            it_behaves_like :check_cut_links do
              let(:base_specs) { [dept_dimer_base, subject] }
              let(:cut_links) do
                {
                  :cm => [[:ctr, free_bond], [:ctl, free_bond]],
                  :ctr => [[:ctl, position_100_cross], [:cm, free_bond]],
                  :ctl => [[:ctr, position_100_cross], [:cm, free_bond]],
                  :csr => [[:csl, position_100_cross]],
                  :csl => [[:csr, position_100_cross]],
                }
              end
            end

            describe 'fixed methyl without relations' do
              let(:cut_links) do
                {
                  :cm => [],
                  :ctr => [[:ctl, position_100_cross]],
                  :ctl => [[:ctr, position_100_cross]],
                  :csr => [[:csl, position_100_cross]],
                  :csl => [[:csr, position_100_cross]],
                }
              end

              it_behaves_like :check_cut_links do
                let(:base_specs) do
                  [dept_dimer_base, dept_methyl_on_dimer_base, subject]
                end
              end

              it_behaves_like :check_cut_links do
                let(:base_specs) do
                  [
                    dept_dimer_base,
                    dept_methyl_on_bridge_base,
                    dept_methyl_on_dimer_base,
                    subject
                  ]
                end
              end
            end

            it_behaves_like :check_cut_links do
              let(:base_specs) do
                [
                  dept_bridge_base,
                  dept_dimer_base,
                  dept_cross_bridge_on_bridges_base,
                  subject
                ]
              end
              let(:cut_links) do
                {
                  :ctr => [[:csr, bond_100_front], [:ctl, position_100_cross]],
                  :ctl => [[:csl, bond_100_front], [:ctr, position_100_cross]],
                  :csr => [[:ctr, bond_100_front], [:csl, position_100_cross]],
                  :csl => [[:ctl, bond_100_front], [:csr, position_100_cross]],
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

            it_behaves_like :check_cut_links do
              subject { dept_intermed_migr_down_common_base }
              let(:cut_links) do
                {
                  :cm => [[:cdr, free_bond]],
                  :cdr => [[:cbr, position_100_cross], [:cm, free_bond]],
                  :cbr => [[:cdr, position_100_cross]]
                }
              end
            end

            it_behaves_like :check_cut_links do
              subject { dept_intermed_migr_down_half_base }
              let(:cut_links) do
                {
                  :cm => [[:cdr, free_bond]],
                  :cdr => [[:cbr, position_100_cross], [:cm, free_bond]],
                  :cbr => [[:cdr, position_100_cross]],
                  :cdl => [[:cbl, non_position_100_cross]],
                  :cbl => [[:cdl, non_position_100_cross]]
                }
              end
            end

            it_behaves_like :check_cut_links do
              subject { dept_intermed_migr_down_full_base }
              let(:cut_links) do
                {
                  :cm => [[:cdr, free_bond]],
                  :cdr => [[:cbr, position_100_cross], [:cm, free_bond]],
                  :cbr => [[:cdr, position_100_cross]],
                  :cdl => [[:cbl, position_100_cross]],
                  :cbl => [[:cdl, position_100_cross]]
                }
              end
            end
          end
        end
      end

    end
  end
end
