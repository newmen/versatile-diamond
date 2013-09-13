require 'spec_helper'

module VersatileDiamond
  module Mcs

    describe MappingResult do
      let(:abr) { md_products.last }

      %w(source products).each do |type|
        describe "##{type}" do
          it { md_atom_map.send(type).should == send("md_#{type}") }
        end
      end

      describe "setup incoherent and unfixed" do
        before(:each) { md_atom_map } # runs atom mapping
        it { methyl_on_bridge.atom(:cm).incoherent?.should be_true }
        it { methyl_on_bridge.atom(:cm).unfixed?.should be_true }
      end

      describe "#changes" do
        it { md_atom_map.changes.should == [
            [[methyl_on_bridge, abr],
              [[methyl_on_bridge.atom(:cb), abr.atom(:ct)]]],
            [[methyl_on_bridge, methyl],
              [[methyl_on_bridge.atom(:cm), methyl.atom(:c)]]]
          ] }

        it { mi_atom_map.changes.should == [
            [[activated_methyl_on_extended_bridge, extended_dimer], [
              [activated_methyl_on_extended_bridge.atom(:cm),
                extended_dimer.atom(:cr)],
              [activated_methyl_on_extended_bridge.atom(:cb),
                extended_dimer.atom(:cl)],
            ]],
            [[activated_dimer, extended_dimer], [
              [activated_dimer.atom(:cl), extended_dimer.atom(:_cr0)],
              [activated_dimer.atom(:cr), extended_dimer.atom(:_cl1)],
            ]]
          ] }
      end

      describe "#full" do
        it { md_atom_map.full.should == [
            [[methyl_on_bridge, abr], [
              [methyl_on_bridge.atom(:cb), abr.atom(:ct)],
              [methyl_on_bridge.atom(:cl), abr.atom(:cl)],
              [methyl_on_bridge.atom(:cr), abr.atom(:cr)],
            ]],
            [[methyl_on_bridge, methyl],
              [[methyl_on_bridge.atom(:cm), methyl.atom(:c)]]]
          ] }
      end

      describe "#add" do
        subject { MappingResult.new(df_source, df_products) }
        let(:specs) { [activated_incoherent_bridge, dimer_dup_ff] }
        let(:full) do
          [[activated_incoherent_bridge.atom(:ct)], [dimer_dup_ff.atom(:cr)]]
        end
        let(:changes) { [[], []] }

        before(:each) { subject.add(specs, full, changes) }

        it { subject.full.should == [
            [[activated_incoherent_bridge, dimer_dup_ff], [[
              activated_incoherent_bridge.atom(:ct),
              dimer_dup_ff.atom(:cr)
            ]]]
          ] }

        it { subject.changes.should == [
            [[activated_incoherent_bridge, dimer_dup_ff], []]
          ] }

        it { dimer_dup_ff.atom(:cr).incoherent?.should be_true }
      end

      describe "#reverse" do
        describe "methyl desorption" do
          it { md_atom_map.reverse.full.should == [
              [[abr, methyl_on_bridge], [
                [abr.atom(:ct), methyl_on_bridge.atom(:cb)],
                [abr.atom(:cl), methyl_on_bridge.atom(:cl)],
                [abr.atom(:cr), methyl_on_bridge.atom(:cr)],
              ]],
              [[methyl, methyl_on_bridge], [
                [methyl.atom(:c), methyl_on_bridge.atom(:cm)]
              ]]
            ] }
        end

        describe "hydrogen migration" do
          it { hm_atom_map.reverse.should be_a(MappingResult) }

          it { hm_atom_map.reverse.changes.should == [
              [[activated_methyl_on_dimer, methyl_on_dimer],
                [[activated_methyl_on_dimer.atom(:cm),
                  methyl_on_dimer.atom(:cm)]]],
              [[dimer, activated_dimer],
                [[dimer.atom(:cr), activated_dimer.atom(:cr)]]]
            ] }
        end

        describe "dimer formation" do
          it { df_atom_map.reverse.changes.should == [
              [[dimer_dup_ff, activated_bridge],
                [[dimer_dup_ff.atom(:cr), activated_bridge.atom(:ct)]]],
              [[dimer_dup_ff, activated_incoherent_bridge],
                [[dimer_dup_ff.atom(:cl),
                  activated_incoherent_bridge.atom(:ct)]]],
            ] }
        end
      end

      let(:ab_dup) { activated_bridge.dup }
      shared_examples_for "checks mob duplication" do
        it { subject.changes.first.first.first.should == ab_dup }
        it { subject.changes.first.last.first.first.
          should == ab_dup.atom(:ct) }

        it { subject.full.first.first.first.should == ab_dup }
        it { subject.full.first.last.first.first.
          should == ab_dup.atom(:ct) }
      end

      describe "#duplicate" do
        let(:aib_dup) { activated_incoherent_bridge.dup }
        let(:d_dup) { dimer_dup_ff.dup }

        subject { df_atom_map.duplicate(
            source: {
              activated_bridge => ab_dup,
              activated_incoherent_bridge => aib_dup,
            },
            products: {
              dimer_dup_ff => d_dup,
            }
          ) }

        it { should be_a(MappingResult) }
        it { should_not == df_atom_map }

        it { subject.source.should == [ab_dup, aib_dup] }
        it { subject.products.should == [d_dup] }

        it { subject.changes.should_not == df_atom_map.changes }
        it { subject.full.should_not == df_atom_map.full }

        it_behaves_like "checks mob duplication"
      end

      describe "#swap_source" do
        subject { df_atom_map }
        before(:each) { subject.swap_source(activated_bridge, ab_dup) }

        it { subject.source.should_not include(activated_bridge) }
        it { subject.source.should include(ab_dup) }

        it_behaves_like "checks mob duplication"
      end

      describe "#complex_source_spec_and_atom" do
        it { ma_atom_map.complex_source_spec_and_atom.
          should == [ma_source.first, c] }

        it { dm_atom_map.complex_source_spec_and_atom.
          should == [activated_methyl_on_bridge, activated_c] }
      end

      describe "#find_positions" do
        it { md_atom_map.find_positions.should be_empty }
        it { hm_atom_map.find_positions.should be_empty }
        it { ma_atom_map.find_positions.should be_empty }

        it { df_atom_map.find_positions.should == [
          activated_bridge.atom(:ct),
          activated_incoherent_bridge.atom(:ct),
          position_front] }
      end
    end

  end
end
