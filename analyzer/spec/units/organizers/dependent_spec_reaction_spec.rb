require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe DependentSpecReaction, type: :organizer do
      describe '#surface_source' do
        it { expect(dept_methyl_activation.surface_source).to eq([ma_source.first]) }
        it { expect(dept_hydrogen_migration.surface_source).to eq(hm_source) }
        it { expect(dept_sierpinski_drop.surface_source).to eq(crm_source) }
      end

      describe '#global_links' do
        let(:spc) { cross_bridge_on_bridges }
        [:cm, :ctl, :ctr].each do |kn|
          let(kn) { spc.atom(kn) }
        end
        let(:global_links) do
          {
            [spc, cm] => [[[spc, ctl], free_bond], [[spc, ctr], free_bond]],
            [spc, ctr] => [[[spc, cm], free_bond], [[spc, ctl], position_100_cross]],
            [spc, ctl] => [[[spc, cm], free_bond], [[spc, ctr], position_100_cross]]
          }
        end
        it { expect(dept_sierpinski_drop.global_links).to match_graph(global_links) }
      end

      describe '#clean_links' do
        describe 'no positions when one reactant' do
          it { expect(dept_sierpinski_drop.clean_links).to be_empty }
        end

        describe 'many reactants' do
          let(:s1) { methyl_on_dimer }
          let(:s2) { activated_dimer }
          let(:a1) { s1.atom(:cr) }
          let(:a2) { s2.atom(:cr) }
          let(:clean_links) do
            {
              [s1, a1] => [[[s2, a2], position_100_front]],
              [s2, a2] => [[[s1, a1], position_100_front]],
            }
          end
          it { expect(dept_hydrogen_migration.clean_links).
            to match_graph(clean_links) }
        end
      end
    end

  end
end
