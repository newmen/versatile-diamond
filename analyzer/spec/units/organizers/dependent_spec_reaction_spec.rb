require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe DependentSpecReaction, type: :organizer do
      describe '#surface_source' do
        it { expect(dept_methyl_activation.surface_source).to eq([ma_source.first]) }
        it { expect(dept_hydrogen_migration.surface_source).to eq(hm_source) }
        it { expect(dept_sierpinski_drop.surface_source).to eq(crm_source) }
      end

      shared_examples_for :check_links do
        describe '#changes' do
          it { expect(subject.changes).to eq(subject.reaction.changes) }
        end

        describe '#links' do
          def count_relations(links)
            links.reduce(0) { |acc, (_, rels)| acc + rels.size }
          end

          let(:positions_num) { count_relations(subject.reaction.links) }
          let(:links_size) do
            positions_num + subject.source.reduce(0) do |acc, s|
              acc + count_relations(s.links)
            end
          end
          it { expect(count_relations(subject.links)).to eq(links_size) }
        end

        describe '#original_links' do
          it { expect(subject.original_links).to match_graph(original_links) }
        end

        describe '#clean_links' do
          it { expect(subject.clean_links).to match_graph(clean_links) }
        end
      end

      it_behaves_like :check_links do
        subject { dept_sierpinski_drop }
        let(:spc) { cross_bridge_on_bridges }
        [:cm, :ctl, :ctr].each do |kn|
          let(kn) { spc.atom(kn) }
        end

        let(:original_links) do
          {
            [spc, cm] => [[[spc, ctl], free_bond], [[spc, ctr], free_bond]],
            [spc, ctr] => [[[spc, cm], free_bond], [[spc, ctl], position_100_cross]],
            [spc, ctl] => [[[spc, cm], free_bond], [[spc, ctr], position_100_cross]]
          }
        end
        let(:clean_links) { {} }
      end

      it_behaves_like :check_links do
        subject { dept_hydrogen_migration }
        let(:s1) { methyl_on_dimer }
        let(:s2) { activated_dimer }
        let(:am) { s1.atom(:cm) }
        let(:a1) { s1.atom(:cr) }
        let(:a2) { s2.atom(:cr) }

        let(:original_links) do
          {
            [s1, am] => [[[s1, a1], free_bond]],
            [s1, a1] => [[[s2, a2], position_100_front], [[s1, am], free_bond]],
            [s2, a2] => [[[s1, a1], position_100_front]]
          }
        end
        let(:clean_links) do
          {
            [s1, a1] => [[[s2, a2], position_100_front]],
            [s2, a2] => [[[s1, a1], position_100_front]]
          }
        end
      end

      it_behaves_like :check_links do
        subject { dept_methyl_incorporation }
        let(:sm) { activated_methyl_on_extended_bridge }
        let(:sd) { activated_dimer }
        let(:amm) { sm.atom(:cm) }
        let(:amb) { sm.atom(:cb) }
        let(:amr) { sm.atom(:cr) }
        let(:aml) { sm.atom(:cl) }
        let(:adr) { sd.atom(:cr) }
        let(:adl) { sd.atom(:cl) }

        let(:original_links) do
          {
            [sd, adl] => [
              [[sd, adr], bond_100_front],
              [[sm, amr], position_100_cross]
            ],
            [sd, adr] => [
              [[sd, adl], bond_100_front],
              [[sm, aml], position_100_cross]
            ],
            [sm, amr] => [
              [[sm, amb], bond_110_front],
              [[sm, aml], position_100_front],
              [[sd, adl], position_100_cross]
            ],
            [sm, aml] => [
              [[sm, amb], bond_110_front],
              [[sm, amr], position_100_front],
              [[sd, adr], position_100_cross]
            ],
            [sm, amb] => [
              [[sm, amr], bond_110_cross],
              [[sm, aml], bond_110_cross],
              [[sm, amm], free_bond]
            ],
            [sm, amm] => [[[sm, amb], free_bond]]
          }
        end
        let(:clean_links) do
          {
            [sd, adl] => [[[sm, amr], position_100_cross]],
            [sd, adr] => [[[sm, aml], position_100_cross]],
            [sm, amr] => [[[sd, adl], position_100_cross]],
            [sm, aml] => [[[sd, adr], position_100_cross]]
          }
        end
      end
    end

  end
end
