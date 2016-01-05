require 'spec_helper'

module VersatileDiamond
  module Mcs

    describe MappingResult do
      %w(source products).each do |type|
        describe "##{type}" do
          it { expect(hm_atom_map.send(type)).to eq(send("hm_#{type}")) }
        end
      end

      describe '#reaction_type' do
        it { expect(ma_atom_map.reaction_type).to eq(:exchange) }
        it { expect(dm_atom_map.reaction_type).to eq(:exchange) }
        it { expect(md_atom_map.reaction_type).to eq(:dissociation) }
        it { expect(hm_atom_map.reaction_type).to eq(:exchange) }
        it { expect(df_atom_map.reaction_type).to eq(:association) }
      end

      describe 'setup incoherent and unfixed' do
        let(:mob) { md_source.first }
        before { md_atom_map } # runs atom mapping

        it { expect(mob.atom(:cm).incoherent?).to be_truthy }
        it { expect(mob.atom(:cm).unfixed?).to be_falsey }
      end

      describe '#changes' do
        shared_examples_for :check_changes do
          it { expect(atoms_map.changes).to match_array(changes) }
        end

        it_behaves_like :check_changes do
          let(:atoms_map) { odhm_atom_map }
          let(:sd) { odhm_source.first }
          let(:pd) { odhm_products.first }
          let(:changes) do
            [
              [[sd, pd], [
                [sd.atom(:cr), pd.atom(:cr)],
                [sd.atom(:cl), pd.atom(:cl)]
              ]]
            ]
          end
        end

        it_behaves_like :check_changes do
          let(:atoms_map) { md_atom_map }
          let(:mod) { md_source.first }
          let(:ab) { md_products.last }
          let(:changes) do
            [
              [[mod, ab], [[mod.atom(:cb), ab.atom(:ct)]]],
              [[mod, methane], [[mod.atom(:cm), methane.atom(:c)]]]
            ]
          end
        end

        it_behaves_like :check_changes do
          let(:atoms_map) { mi_atom_map }
          let(:amoeb) { mi_source.first }
          let(:ad) { mi_source.last }
          let(:ed) { mi_product.first }
          let(:changes) do
            [
              [[amoeb, ed], [
                [amoeb.atom(:cm), ed.atom(:cr)],
                [amoeb.atom(:cb), ed.atom(:cl)],
              ]],
              [[ad, ed], [
                [ad.atom(:cl), ed.atom(:crb)],
                [ad.atom(:cr), ed.atom(:_cr0)],
              ]]
            ]
          end
        end
      end

      describe '#full' do
        let(:mod) { md_source.first }
        let(:ab) { md_products.last }
        let(:full) do
          [
            [[mod, methane], [[mod.atom(:cm), methane.atom(:c)]]],
            [[mod, ab], [
              [mod.atom(:cb), ab.atom(:ct)],
              [mod.atom(:cl), ab.atom(:cl)],
              [mod.atom(:cr), ab.atom(:cr)],
            ]]
          ]
        end

        it { expect(md_atom_map.full).to match_array(full) }
      end

      describe '#used_atoms_of' do
        describe 'methyl deactivation' do
          let(:amob) { dm_source.first }
          it { expect(dm_atom_map.used_atoms_of(amob)).to eq([amob.atom(:cm)]) }
        end

        describe 'dimer drop' do
          let(:d) { df_products.first }
          let(:atoms) { [:cr, :cl].map { |kn| d.atom(kn) } }
          let(:dd_atom_map) { df_atom_map.reverse }
          it { expect(dd_atom_map.used_atoms_of(d)).to match_array(atoms) }
        end
      end

      describe 'other_side' do
        describe 'hydrogen migration' do
          let(:mod) { hm_source.first }
          let(:ad) { hm_source.last }
          let(:amod) { hm_products.first }
          let(:d) { hm_products.last }

          it { expect(hm_atom_map.other_side(mod, mod.atom(:cm))).
            to match_array([amod, amod.atom(:cm)]) }

          it { expect(hm_atom_map.other_side(amod, amod.atom(:cm))).
            to match_array([mod, mod.atom(:cm)]) }

          it { expect(hm_atom_map.other_side(d, d.atom(:cr))).
            to match_array([ad, ad.atom(:cr)]) }

          it { expect(hm_atom_map.other_side(ad, ad.atom(:cr))).
            to match_array([d, d.atom(:cr)]) }
        end

        describe 'dimer formation' do
          let(:ab) { df_source.first }
          let(:aib) { df_source.last }
          let(:d) { df_products.first }

          it { expect(df_atom_map.other_side(ab, ab.atom(:ct))).
            to match_array([d, d.atom(:cr)]) }

          it { expect(df_atom_map.other_side(aib, aib.atom(:ct))).
            to match_array([d, d.atom(:cl)]) }

          it { expect(df_atom_map.other_side(d, d.atom(:cr))).
            to match_array([ab, ab.atom(:ct)]) }

          it { expect(df_atom_map.other_side(d, d.atom(:cl))).
            to match_array([aib, aib.atom(:ct)]) }
        end
      end

      describe '#add' do
        subject { MappingResult.new(df_source, df_products) }
        let(:ab) { df_source.first }
        let(:aib) { df_source.last }
        let(:d) { df_products.first }

        let(:m_full) { [[aib.atom(:ct)], [d.atom(:cr)]] }
        let(:r_full) { [[[aib, d], [[aib.atom(:ct), d.atom(:cr)]]]] }
        let(:m_changes) { [[], []] }
        let(:r_changes) { [[[aib, d], []]] }

        before(:each) { subject.add([aib, d], m_full, m_changes) }

        it { expect(subject.full).to match_array(r_full) }
        it { expect(subject.changes).to match_array(r_changes) }
        it { expect(d.atom(:cr).incoherent?).to be_truthy }
      end

      describe '#reverse' do
        describe 'methyl desorption' do
          let(:mob) { md_source.first }
          let(:ab) { md_products.last }
          let(:full) do
            [
              [[methane, mob], [[methane.atom(:c), mob.atom(:cm)]]],
              [[ab, mob], [
                [ab.atom(:ct), mob.atom(:cb)],
                [ab.atom(:cl), mob.atom(:cl)],
                [ab.atom(:cr), mob.atom(:cr)],
              ]]
            ]
          end

          it { expect(md_atom_map.reverse.full).to match_array(full) }
        end

        describe 'hydrogen migration' do
          let(:mod) { hm_source.first }
          let(:ad) { hm_source.last }
          let(:amod) { hm_products.first }
          let(:d) { hm_products.last }
          let(:changes) do
            [
              [[amod, mod], [[amod.atom(:cm), mod.atom(:cm)]]],
              [[d, ad], [[d.atom(:cr), ad.atom(:cr)]]]
            ]
          end

          it { expect(hm_atom_map.reverse).to be_a(MappingResult) }
          it { expect(hm_atom_map.reverse.changes).to match_array(changes) }
        end

        describe 'dimer formation' do
          let(:ab) { df_source.first }
          let(:aib) { df_source.last }
          let(:d) { df_products.first }
          let(:changes) do
            [
              [[d, ab], [[d.atom(:cr), ab.atom(:ct)]]],
              [[d, aib], [[d.atom(:cl), aib.atom(:ct)]]]
            ]
          end
          it { expect(df_atom_map.reverse.changes).to match_array(changes) }
        end
      end

      describe '#duplicate' do
        let(:ab) { df_source.first }
        let(:aib) { df_source.last }
        let(:d) { df_products.first }

        let(:ab_dup) { activated_bridge.dup }
        let(:aib_dup) { activated_incoherent_bridge.dup }
        let(:d_dup) { dimer.dup }

        let(:duplication_params) do
          {
            source: { ab => ab_dup, aib => aib_dup },
            products: { d => d_dup }
          }
        end

        subject { df_atom_map.duplicate(duplication_params) }

        it { should be_a(MappingResult) }
        it { should_not == df_atom_map }

        it { expect(subject.source).to match_array([ab_dup, aib_dup]) }
        it { expect(subject.products).to eq([d_dup]) }

        it { expect(subject.changes).not_to eq(df_atom_map.changes) }
        it { expect(subject.full).not_to eq(df_atom_map.full) }
      end

      describe '#swap' do
        subject { df_atom_map }
        let(:ab) { df_source.first }
        let(:ab_dup) { activated_bridge.dup }
        before(:each) { subject.swap(:source, ab, ab_dup) }

        it { expect(subject.source).not_to include(ab) }
        it { expect(subject.source).to include(ab_dup) }
      end

      describe 'exnchange atoms' do
        shared_examples_for :check_exchanges_in_result do
          shared_examples_for :check_atoms do
            subject { atoms.first.map(&:first) + atoms.last.map(&:first) }
            it { should include(new_atom) }
            it { should_not include(old_atom) }
          end

          it_behaves_like :check_atoms do
            let(:atoms) { df_atom_map.changes.map(&:last) }
          end

          it_behaves_like :check_atoms do
            let(:atoms) { df_atom_map.full.map(&:last) }
          end
        end

        describe '#swap_atom' do
          let(:ab) { df_source.first }
          let(:old_atom) { ab.atom(:ct) }
          let(:new_atom) { old_atom.dup }
          before(:each) do
            df_atom_map.swap_atom(ab, old_atom, new_atom)
          end

          it_behaves_like :check_exchanges_in_result
        end

        describe '#apply_relevants' do
          let(:ab) { df_source.first }
          let(:old_atom) { ab.atom(:ct) }
          let(:new_atom) { incoherent_activated_cd }
          before(:each) do
            df_atom_map.apply_relevants(ab, old_atom, new_atom)
          end

          it { expect(df_atom_map.products.first.atom(:cl).incoherent?).
            to be_truthy }
          it { expect(df_atom_map.products.first.atom(:cr).incoherent?).
            to be_truthy }

          it_behaves_like :check_exchanges_in_result
        end
      end

      describe '#complex_source_spec_and_atom' do
        describe 'methyl activation' do
          let(:spec) { ma_source.first }
          it { expect(ma_atom_map.complex_source_spec_and_atom).
            to match_array([spec, spec.atom(:cm)]) }
        end

        describe 'methyl deactivation' do
          let(:spec) { dm_source.first }
          it { expect(dm_atom_map.complex_source_spec_and_atom).
            to match_array([spec, spec.atom(:cm)]) }
        end
      end
    end

  end
end
