require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe Essence, use: :engine_generator do
        let(:base_specs) { [] }
        let(:specific_specs) { [] }
        let(:generator) do
          stub_generator(base_specs: base_specs, specific_specs: specific_specs)
        end

        let(:specie) { generator.specie_class(subject.name) }
        let(:essence) { specie.essence }

        describe 'graphs' do
          Algorithm::Support::RoleChecker::ANCHOR_KEYNAMES.each do |keyname|
            let(keyname) { subject.spec.atom(keyname) }
          end

          shared_examples_for :check_cut_links do
            # each method should not change the state of essence
            it 'all public methods' do
              expect(essence.cut_links).to match_graph(cut_links)
            end
          end

          it_behaves_like :check_cut_links do
            subject { dept_bridge_base }
            let(:base_specs) { [subject] }
            let(:cut_links) do
              {
                ct => [[cl, bond_110_cross], [cr, bond_110_cross]],
                cr => [[ct, bond_110_front]],
                cl => [[ct, bond_110_front]]
              }
            end
          end

          describe 'like methyl on bridge' do
            let(:cut_links) do
              {
                cm => [[cb, free_bond]],
                cb => [[cm, free_bond]]
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
                cb => [[c1, free_bond]],
                c1 => [[cb, free_bond], [c2, free_bond]],
                c2 => [[c1, free_bond]]
              }
            end
          end

          it_behaves_like :check_cut_links do
            subject { dept_dimer_base }
            let(:base_specs) { [dept_bridge_base, subject] }
            let(:cut_links) do
              {
                cr => [[cl, bond_100_front]],
                cl => [[cr, bond_100_front]]
              }
            end
          end

          it_behaves_like :check_cut_links do
            subject { dept_two_methyls_on_dimer_base }
            let(:base_specs) { [dept_dimer_base, subject] }
            let(:cut_links) do
              {
                c1 => [[cr, free_bond]],
                c2 => [[cl, free_bond]],
                cr => [[c1, free_bond]],
                cl => [[c2, free_bond]]
              }
            end
          end

          it_behaves_like :check_cut_links do
            subject { dept_activated_methyl_on_incoherent_bridge }
            let(:base_specs) { [dept_methyl_on_bridge_base] }
            let(:specific_specs) { [subject] }
            let(:cut_links) do
              {
                cb => [],
                cm => []
              }
            end
          end

          it_behaves_like :check_cut_links do
            subject { dept_methyl_on_dimer_base }
            let(:base_specs) do
              [dept_bridge_base, dept_methyl_on_bridge_base, subject]
            end
            let(:cut_links) do
              {
                cr => [[cl, bond_100_front]],
                cl => [[cr, bond_100_front]]
              }
            end
          end

          it_behaves_like :check_cut_links do
            subject { dept_three_bridges_base }
            let(:base_specs) { [dept_bridge_base, subject] }
            let(:cut_links) do
              {
                ct => [],
                cc => []
              }
            end
          end

          it_behaves_like :check_cut_links do
            subject { dept_right_hydrogenated_bridge }
            let(:base_specs) { [dept_bridge_base] }
            let(:specific_specs) { [subject] }
            let(:cut_links) do
              {
                cr => []
              }
            end
          end

          describe 'different dept_cross_bridge_on_bridges_base' do
            subject { dept_cross_bridge_on_bridges_base }

            it_behaves_like :check_cut_links do
              let(:base_specs) { [dept_bridge_base, subject] }
              let(:cut_links) do
                {
                  cm => [[ctl, free_bond], [ctr, free_bond]],
                  ctr => [[ctl, position_100_cross], [cm, free_bond]],
                  ctl => [[ctr, position_100_cross], [cm, free_bond]],
                }
              end
            end

            it_behaves_like :check_cut_links do
              let(:base_specs) do
                [dept_bridge_base, dept_methyl_on_bridge_base, subject]
              end
              let(:cut_links) do
                {
                  cm => [],
                  ctr => [[ctl, position_100_cross]],
                  ctl => [[ctr, position_100_cross]],
                }
              end
            end
          end

          describe 'different dept_cross_bridge_on_dimers_base' do
            subject { dept_cross_bridge_on_dimers_base }

            it_behaves_like :check_cut_links do
              let(:base_specs) { [dept_dimer_base, subject] }
              let(:cut_links) do
                {
                  cm => [[ctl, free_bond], [ctr, free_bond]],
                  ctr => [[ctl, position_100_cross], [cm, free_bond]],
                  ctl => [[ctr, position_100_cross], [cm, free_bond]],
                  csr => [[csl, position_100_cross]],
                  csl => [[csr, position_100_cross]],
                }
              end
            end

            it_behaves_like :check_cut_links do
              let(:base_specs) do
                [dept_dimer_base, dept_methyl_on_dimer_base, subject]
              end
              let(:cut_links) do
                {
                  cm => [],
                  ctr => [[ctl, position_100_cross]],
                  ctl => [[ctr, position_100_cross]],
                  csr => [[csl, position_100_cross]],
                  csl => [[csr, position_100_cross]],
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
                  cm => [],
                  cdr => [[cbr, position_100_cross]],
                  cbr => [[cdr, position_100_cross]]
                }
              end
            end

            it_behaves_like :check_cut_links do
              subject { dept_intermed_migr_down_half_base }
              let(:cut_links) do
                {
                  cm => [],
                  cdr => [[cbr, position_100_cross]],
                  cbr => [[cdr, position_100_cross]],
                  cdl => [[cbl, non_position_100_cross]],
                  cbl => [[cdl, non_position_100_cross]]
                }
              end
            end

            it_behaves_like :check_cut_links do
              subject { dept_intermed_migr_down_full_base }
              let(:cut_links) do
                {
                  cm => [],
                  cdr => [[cbr, position_100_cross]],
                  cbr => [[cdr, position_100_cross]],
                  cdl => [[cbl, position_100_cross]],
                  cbl => [[cdl, position_100_cross]]
                }
              end
            end
          end
        end
      end

    end
  end
end
