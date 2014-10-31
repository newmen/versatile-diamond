require 'spec_helper'

module VersatileDiamond
  module Mcs

    describe MappingResult do
      %w(source products).each do |type|
        describe "##{type}" do
          it { expect(md_atom_map.send(type)).to eq(send("md_#{type}")) }
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
        describe 'methyl desorption' do
          let(:mod) { md_source.first }

          it { expect(md_atom_map.changes).to match_array([
              [[mod, abridge_dup], [[mod.atom(:cb), abridge_dup.atom(:ct)]]],
              [[mod, methyl], [[mod.atom(:cm), methyl.atom(:c)]]]
            ]) }
        end

        describe 'methyl incorporation' do
          let(:amoe_bridge) { activated_methyl_on_extended_bridge }
          it { expect(mi_atom_map.changes).to match_array([
              [[amoe_bridge, extended_dimer], [
                [amoe_bridge.atom(:cm), extended_dimer.atom(:cr)],
                [amoe_bridge.atom(:cb), extended_dimer.atom(:cl)],
              ]],
              [[activated_dimer, extended_dimer], [
                [activated_dimer.atom(:cl), extended_dimer.atom(:crb)],
                [activated_dimer.atom(:cr), extended_dimer.atom(:_cr0)],
              ]]
            ]) }
        end
      end

      describe '#full' do
        let(:mod) { md_source.first }

        it { expect(md_atom_map.full).to match_array([
            [[mod, methyl], [[mod.atom(:cm), methyl.atom(:c)]]],
            [[mod, abridge_dup], [
              [mod.atom(:cb), abridge_dup.atom(:ct)],
              [mod.atom(:cl), abridge_dup.atom(:cl)],
              [mod.atom(:cr), abridge_dup.atom(:cr)],
            ]]
          ]) }
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
          it { expect(hm_atom_map.other_side(
              methyl_on_dimer, methyl_on_dimer.atom(:cm))).
            to match_array([
              activated_methyl_on_dimer, activated_methyl_on_dimer.atom(:cm)
            ]) }

          it { expect(hm_atom_map.other_side(
              activated_methyl_on_dimer, activated_methyl_on_dimer.atom(:cm))).
            to match_array([
              methyl_on_dimer, methyl_on_dimer.atom(:cm)
            ]) }

          it { expect(hm_atom_map.other_side(dimer, dimer.atom(:cr))).
            to match_array([activated_dimer, activated_dimer.atom(:cr)]) }

          it { expect(hm_atom_map.other_side(
              activated_dimer, activated_dimer.atom(:cr))).
            to match_array([dimer, dimer.atom(:cr)]) }
        end

        describe 'dimer formation' do
          it { expect(df_atom_map.other_side(
              activated_bridge, activated_bridge.atom(:ct))).
            to match_array([dimer_dup_ff, dimer_dup_ff.atom(:cr)]) }

          it { expect(df_atom_map.other_side(
              activated_incoherent_bridge,
              activated_incoherent_bridge.atom(:ct))).
            to match_array([dimer_dup_ff, dimer_dup_ff.atom(:cl)]) }

          it { expect(df_atom_map.other_side(
              dimer_dup_ff, dimer_dup_ff.atom(:cr))).
            to match_array([activated_bridge, activated_bridge.atom(:ct)]) }

          it { expect(df_atom_map.other_side(
              dimer_dup_ff, dimer_dup_ff.atom(:cl))).
            to match_array([
              activated_incoherent_bridge,
              activated_incoherent_bridge.atom(:ct)
            ]) }
        end
      end

      describe '#add' do
        subject { MappingResult.new(df_source, df_products) }
        let(:specs) { [activated_incoherent_bridge, dimer_dup_ff] }
        let(:full) do
          [[activated_incoherent_bridge.atom(:ct)], [dimer_dup_ff.atom(:cr)]]
        end
        let(:changes) { [[], []] }

        before(:each) { subject.add(specs, full, changes) }

        it { expect(subject.full).to match_array([
            [[activated_incoherent_bridge, dimer_dup_ff], [[
              activated_incoherent_bridge.atom(:ct),
              dimer_dup_ff.atom(:cr)
            ]]]
          ]) }

        it { expect(subject.changes).to match_array([
            [[activated_incoherent_bridge, dimer_dup_ff], []]
          ]) }

        it { expect(dimer_dup_ff.atom(:cr).incoherent?).to be_truthy }
      end

      describe '#reverse' do
        describe 'methyl desorption' do
          let(:mob) { md_source.first }

          it { expect(md_atom_map.reverse.full).to match_array([
              [[methyl, mob], [[methyl.atom(:c), mob.atom(:cm)]]],
              [[abridge_dup, mob], [
                [abridge_dup.atom(:ct), mob.atom(:cb)],
                [abridge_dup.atom(:cl), mob.atom(:cl)],
                [abridge_dup.atom(:cr), mob.atom(:cr)],
              ]]
            ]) }
        end

        describe 'hydrogen migration' do
          it { expect(hm_atom_map.reverse).to be_a(MappingResult) }

          it { expect(hm_atom_map.reverse.changes).to match_array([
              [[activated_methyl_on_dimer, methyl_on_dimer],
                [[activated_methyl_on_dimer.atom(:cm),
                  methyl_on_dimer.atom(:cm)]]],
              [[dimer, activated_dimer],
                [[dimer.atom(:cr), activated_dimer.atom(:cr)]]]
            ]) }
        end

        describe 'dimer formation' do
          it { expect(df_atom_map.reverse.changes).to match_array([
              [[dimer_dup_ff, activated_bridge],
                [[dimer_dup_ff.atom(:cr), activated_bridge.atom(:ct)]]],
              [[dimer_dup_ff, activated_incoherent_bridge],
                [[dimer_dup_ff.atom(:cl),
                  activated_incoherent_bridge.atom(:ct)]]],
            ]) }
        end
      end

      shared_examples_for :checks_mob_duplication do
        it { expect(subject.changes.first.first.first).to eq(abridge_dup) }
        it { expect(subject.changes.first.last.first.first).
          to eq(abridge_dup.atom(:ct)) }

        it { expect(subject.full.first.first.first).to eq(abridge_dup) }
        it { expect(subject.full.first.last.first.first).
          to eq(abridge_dup.atom(:ct)) }
      end

      describe '#duplicate' do
        let(:aib_dup) { activated_incoherent_bridge.dup }
        let(:d_dup) { dimer_dup_ff.dup }

        subject { df_atom_map.duplicate(
            source: {
              activated_bridge => abridge_dup,
              activated_incoherent_bridge => aib_dup,
            },
            products: {
              dimer_dup_ff => d_dup,
            }
          ) }

        it { should be_a(MappingResult) }
        it { should_not == df_atom_map }

        it { expect(subject.source).to match_array([abridge_dup, aib_dup]) }
        it { expect(subject.products).to eq([d_dup]) }

        it { expect(subject.changes).not_to eq(df_atom_map.changes) }
        it { expect(subject.full).not_to eq(df_atom_map.full) }

        it_behaves_like :checks_mob_duplication
      end

      describe '#swap_source' do
        subject { df_atom_map }
        before(:each) { subject.swap_source(activated_bridge, abridge_dup) }

        it { expect(subject.source).not_to include(activated_bridge) }
        it { expect(subject.source).to include(abridge_dup) }

        it_behaves_like :checks_mob_duplication
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
          let(:old_atom) { activated_bridge.atom(:ct) }
          let(:new_atom) { old_atom.dup }
          before(:each) do
            df_atom_map.swap_atom(activated_bridge, old_atom, new_atom)
          end

          it_behaves_like :check_exchanges_in_result
        end

        describe '#apply_relevants' do
          let(:old_atom) { activated_bridge.atom(:ct) }
          let(:new_atom) { incoherent_activated_cd }
          before(:each) do
            df_atom_map.apply_relevants(activated_bridge, old_atom, new_atom)
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
