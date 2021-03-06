require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        describe SpecieEntryNodes, type: :algorithm do
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
          let(:backbone) { SpecieBackbone.new(generator, specie) }
          let(:entry_nodes) { described_class.new(backbone.final_graph).list }

          it_behaves_like :check_entry_nodes do
            subject { dept_bridge_base }
            let(:base_specs) { [subject] }
            let(:points_list) { [[:ct]] }
          end

          it_behaves_like :check_entry_nodes do
            subject { dept_methyl_on_bridge_base }
            let(:base_specs) { [dept_bridge_base, subject] }
            let(:points_list) { [[:cb]] }
          end

          describe 'different dept_vinyl_on_bridge_base' do
            subject { dept_vinyl_on_bridge_base }

            it_behaves_like :check_entry_nodes do
              let(:base_specs) { [dept_bridge_base, subject] }
              let(:points_list) { [[:cb]] }
            end

            it_behaves_like :check_entry_nodes do
              let(:base_specs) { [dept_methyl_on_bridge_base, subject] }
              let(:points_list) { [[:c1]] }
            end
          end


          it_behaves_like :check_entry_nodes do
            subject { dept_high_bridge_base }
            let(:base_specs) do
              [dept_bridge_base, dept_methyl_on_bridge_base, subject]
            end
            let(:points_list) { [[:cb]] }
          end

          it_behaves_like :check_entry_nodes do
            subject { dept_very_high_bridge_base }
            let(:base_specs) do
              [
                dept_bridge_base,
                dept_methyl_on_bridge_base,
                dept_high_bridge_base,
                subject
              ]
            end
            let(:points_list) { [[:c1]] }
          end

          it_behaves_like :check_entry_nodes do
            before { subject.replace_base_spec(dept_high_bridge_base) }
            subject { dept_incoherent_very_high_bridge }
            let(:base_specs) do
              [dept_bridge_base, dept_high_bridge_base, dept_very_high_bridge_base]
            end
            let(:specific_specs) { [subject] }
            let(:points_list) { [[:cm]] }
          end

          it_behaves_like :check_entry_nodes do
            subject { dept_dimer_base }
            let(:base_specs) { [dept_bridge_base, subject] }
            let(:points_list) { [[:cl]] }
          end

          it_behaves_like :check_entry_nodes do
            subject { dept_two_methyls_on_dimer_base }
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
            let(:points_list) { [[:cl]] }
          end

          it_behaves_like :check_entry_nodes do
            subject { dept_activated_methyl_on_incoherent_bridge }
            let(:base_specs) { [dept_methyl_on_bridge_base] }
            let(:specific_specs) { [subject] }
            let(:points_list) { [[:cb, :cm]] }
          end

          describe 'different methyl on dimer' do
            subject { dept_methyl_on_dimer_base }
            let(:points_list) { [[:cr], [:cl]] }

            it_behaves_like :check_entry_nodes do
              let(:base_specs) do
                [dept_bridge_base, dept_methyl_on_bridge_base, subject]
              end
            end

            it_behaves_like :check_entry_nodes do
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
            let(:points_list) { [[:cr], [:cl]] }

            it_behaves_like :check_entry_nodes do
              let(:base_specs) do
                [dept_bridge_base, dept_vinyl_on_bridge_base, subject]
              end
            end

            it_behaves_like :check_entry_nodes do
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

          it_behaves_like :check_entry_nodes do
            subject { dept_three_bridges_base }
            let(:base_specs) { [dept_bridge_base, subject] }
            let(:points_list) { [[:cc]] }
          end

          it_behaves_like :check_entry_nodes do
            subject { dept_bridge_with_dimer_base }
            let(:base_specs) { [dept_bridge_base, dept_dimer_base, subject] }
            let(:points_list) { [[:cr]] }
          end

          it_behaves_like :check_entry_nodes do
            subject { dept_activated_methyl_on_bridge }
            let(:base_specs) { [dept_methyl_on_bridge_base] }
            let(:specific_specs) { [subject] }
            let(:points_list) { [[:cm]] }
          end

          it_behaves_like :check_entry_nodes do
            subject { dept_activated_dimer }
            let(:base_specs) { [dept_dimer_base] }
            let(:specific_specs) { [subject] }
            let(:points_list) { [[:cr]] }
          end

          describe 'different dept_cross_bridge_on_bridges_base' do
            subject { dept_cross_bridge_on_bridges_base }

            it_behaves_like :check_entry_nodes do
              let(:base_specs) { [dept_bridge_base, subject] }
              let(:points_list) { [[:ctl]] }
            end

            it_behaves_like :check_entry_nodes do
              let(:base_specs) do
                [dept_bridge_base, dept_methyl_on_bridge_base, subject]
              end
              let(:points_list) { [[:cm]] }
            end
          end

          describe 'different dept_cross_bridge_on_dimers_base' do
            subject { dept_cross_bridge_on_dimers_base }

            it_behaves_like :check_entry_nodes do
              let(:base_specs) { [dept_dimer_base, subject] }
              let(:points_list) { [[:ctl]] }
            end

            describe 'methyl is anchor' do
              let(:points_list) { [[:cm]] }

              it_behaves_like :check_entry_nodes do
                let(:base_specs) do
                  [dept_dimer_base, dept_methyl_on_dimer_base, subject]
                end
              end

              it_behaves_like :check_entry_nodes do
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

            it_behaves_like :check_entry_nodes do
              let(:base_specs) do
                [dept_bridge_base, dept_cross_bridge_on_bridges_base, subject]
              end
              let(:points_list) { [[:csl]] }
            end
          end

          describe 'different dept_lower_methyl_on_half_extended_bridge_base' do
            subject { dept_lower_methyl_on_half_extended_bridge_base }
            let(:points_list) { [[:cbr], [:cr]] }

            it_behaves_like :check_entry_nodes do
              let(:base_specs) { [dept_bridge_base, subject] }
            end

            it_behaves_like :check_entry_nodes do
              let(:base_specs) do
                [dept_bridge_base, dept_methyl_on_right_bridge_base, subject]
              end
            end
          end

          it_behaves_like :check_entry_nodes do
            subject { dept_intermed_migr_down_bridge_base }
            let(:base_specs) do
              [dept_bridge_base, dept_methyl_on_bridge_base, subject]
            end
            let(:points_list) { [[:cm]] }
          end

          describe 'intermediate specie of migration down process' do
            describe 'all atoms are anchored' do
              let(:base_specs) do
                [dept_methyl_on_bridge_base, dept_methyl_on_dimer_base, subject]
              end

              it_behaves_like :check_entry_nodes do
                subject { dept_intermed_migr_down_common_base }
                let(:points_list) { [[:cdr]] }
              end

              describe 'many bottom entry points' do
                let(:points_list) { [[:cdr, :cdl], [:cbl]] } # why this is cool?!

                it_behaves_like :check_entry_nodes do
                  subject { dept_intermed_migr_down_half_base }
                end

                it_behaves_like :check_entry_nodes do
                  subject { dept_intermed_migr_down_full_base }
                end
              end
            end

            describe 'not all atoms are anchored' do
              let(:base_specs) do
                [
                  dept_bridge_base,
                  dept_methyl_on_bridge_base,
                  dept_methyl_on_dimer_base,
                  subject
                ]
              end
              let(:points_list) { [[:cdr], [:cm]] }

              it_behaves_like :check_entry_nodes do
                subject { dept_intermed_migr_down_common_base }
              end

              it_behaves_like :check_entry_nodes do
                subject { dept_intermed_migr_down_half_base }
              end

              it_behaves_like :check_entry_nodes do
                subject { dept_intermed_migr_down_full_base }
              end
            end

            describe 'just methyl is anchored (when there are reactions)' do
              let(:base_specs) do
                [
                  dept_bridge_base,
                  dept_methyl_on_bridge_base,
                  dept_methyl_on_dimer_base,
                  subject
                ]
              end
              let(:points_list) { [[:cm]] }

              it_behaves_like :check_entry_nodes do
                subject { dept_intermed_migr_down_common_base }
                let(:typical_reactions) { [dept_intermed_migr_dc_drop] }
              end

              it_behaves_like :check_entry_nodes do
                subject { dept_intermed_migr_down_half_base }
                let(:typical_reactions) { [dept_intermed_migr_dh_drop] }
              end

              it_behaves_like :check_entry_nodes do
                subject { dept_intermed_migr_down_full_base }
                let(:typical_reactions) { [dept_intermed_migr_df_drop] }
              end
            end
          end
        end

      end
    end
  end
end
