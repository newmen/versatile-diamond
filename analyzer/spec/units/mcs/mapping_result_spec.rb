require 'spec_helper'

module VersatileDiamond
  module Mcs

    describe MappingResult do
      %w(source products).each do |type|
        describe "##{type}" do
          it { md_atom_map.send(type).should == send("md_#{type}") }
        end
      end

      describe "#reaction_type" do
        it { ma_atom_map.reaction_type.should == :exchange }
        it { dm_atom_map.reaction_type.should == :exchange }
        it { md_atom_map.reaction_type.should == :dissociation }
        it { hm_atom_map.reaction_type.should == :exchange }
        it { df_atom_map.reaction_type.should == :association }
      end

      describe "setup incoherent and unfixed" do
        before(:each) { md_atom_map } # runs atom mapping
        it { methyl_on_bridge.atom(:cm).incoherent?.should be_true }
        it { methyl_on_bridge.atom(:cm).unfixed?.should be_true }
      end

      describe "#changes" do
        it { md_atom_map.changes.should =~ [
            [[methyl_on_bridge, abridge_dup],
              [[methyl_on_bridge.atom(:cb), abridge_dup.atom(:ct)]]],
            [[methyl_on_bridge, methyl],
              [[methyl_on_bridge.atom(:cm), methyl.atom(:c)]]]
          ] }

        it { mi_atom_map.changes.should =~ [
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
        it { md_atom_map.full.should =~ [
            [[methyl_on_bridge, abridge_dup], [
              [methyl_on_bridge.atom(:cb), abridge_dup.atom(:ct)],
              [methyl_on_bridge.atom(:cl), abridge_dup.atom(:cl)],
              [methyl_on_bridge.atom(:cr), abridge_dup.atom(:cr)],
            ]],
            [[methyl_on_bridge, methyl],
              [[methyl_on_bridge.atom(:cm), methyl.atom(:c)]]]
          ] }
      end

      describe "other_side" do
        describe "hydrogen migration" do
          it { hm_atom_map.other_side(
              methyl_on_dimer, methyl_on_dimer.atom(:cm)).
            should =~ [
              activated_methyl_on_dimer, activated_methyl_on_dimer.atom(:cm)
            ] }

          it { hm_atom_map.other_side(
              activated_methyl_on_dimer, activated_methyl_on_dimer.atom(:cm)).
            should =~ [
              methyl_on_dimer, methyl_on_dimer.atom(:cm)
            ] }

          it { hm_atom_map.other_side(dimer, dimer.atom(:cr)).should =~ [
              activated_dimer, activated_dimer.atom(:cr)
            ] }

          it { hm_atom_map.other_side(
              activated_dimer, activated_dimer.atom(:cr)).
            should =~ [dimer, dimer.atom(:cr)] }
        end

        describe "dimer formation" do
          it { df_atom_map.other_side(
              activated_bridge, activated_bridge.atom(:ct)).
            should =~ [dimer_dup_ff, dimer_dup_ff.atom(:cr)] }

          it { df_atom_map.other_side(
              activated_incoherent_bridge,
              activated_incoherent_bridge.atom(:ct)).
            should =~ [dimer_dup_ff, dimer_dup_ff.atom(:cl)] }

          it { df_atom_map.other_side(
              dimer_dup_ff, dimer_dup_ff.atom(:cr)).
            should =~ [activated_bridge, activated_bridge.atom(:ct)] }

          it { df_atom_map.other_side(
              dimer_dup_ff, dimer_dup_ff.atom(:cl)).
            should =~ [
              activated_incoherent_bridge,
              activated_incoherent_bridge.atom(:ct)
            ] }
        end
      end

      describe "#add" do
        subject { MappingResult.new(df_source, df_products) }
        let(:specs) { [activated_incoherent_bridge, dimer_dup_ff] }
        let(:full) do
          [[activated_incoherent_bridge.atom(:ct)], [dimer_dup_ff.atom(:cr)]]
        end
        let(:changes) { [[], []] }

        before(:each) { subject.add(specs, full, changes) }

        it { subject.full.should =~ [
            [[activated_incoherent_bridge, dimer_dup_ff], [[
              activated_incoherent_bridge.atom(:ct),
              dimer_dup_ff.atom(:cr)
            ]]]
          ] }

        it { subject.changes.should =~ [
            [[activated_incoherent_bridge, dimer_dup_ff], []]
          ] }

        it { dimer_dup_ff.atom(:cr).incoherent?.should be_true }
      end

      describe "#reverse" do
        describe "methyl desorption" do
          it { md_atom_map.reverse.full.should =~ [
              [[abridge_dup, methyl_on_bridge], [
                [abridge_dup.atom(:ct), methyl_on_bridge.atom(:cb)],
                [abridge_dup.atom(:cl), methyl_on_bridge.atom(:cl)],
                [abridge_dup.atom(:cr), methyl_on_bridge.atom(:cr)],
              ]],
              [[methyl, methyl_on_bridge], [
                [methyl.atom(:c), methyl_on_bridge.atom(:cm)]
              ]]
            ] }

          it { hm_atom_map.reverse.reaction_type.should == :exchange }
          it { md_atom_map.reverse.reaction_type.should == :association }
          it { df_atom_map.reverse.reaction_type.should == :dissociation }
        end

        describe "hydrogen migration" do
          it { hm_atom_map.reverse.should be_a(MappingResult) }

          it { hm_atom_map.reverse.changes.should =~ [
              [[activated_methyl_on_dimer, methyl_on_dimer],
                [[activated_methyl_on_dimer.atom(:cm),
                  methyl_on_dimer.atom(:cm)]]],
              [[dimer, activated_dimer],
                [[dimer.atom(:cr), activated_dimer.atom(:cr)]]]
            ] }
        end

        describe "dimer formation" do
          it { df_atom_map.reverse.changes.should =~ [
              [[dimer_dup_ff, activated_bridge],
                [[dimer_dup_ff.atom(:cr), activated_bridge.atom(:ct)]]],
              [[dimer_dup_ff, activated_incoherent_bridge],
                [[dimer_dup_ff.atom(:cl),
                  activated_incoherent_bridge.atom(:ct)]]],
            ] }
        end
      end

      shared_examples_for "checks mob duplication" do
        it { subject.changes.first.first.first.should == abridge_dup }
        it { subject.changes.first.last.first.first.
          should == abridge_dup.atom(:ct) }

        it { subject.full.first.first.first.should == abridge_dup }
        it { subject.full.first.last.first.first.
          should == abridge_dup.atom(:ct) }
      end

      describe "#duplicate" do
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

        it { subject.source.should =~ [abridge_dup, aib_dup] }
        it { subject.products.should =~ [d_dup] }

        it { subject.changes.should_not == df_atom_map.changes }
        it { subject.full.should_not == df_atom_map.full }

        it_behaves_like "checks mob duplication"
      end

      describe "#swap_source" do
        subject { df_atom_map }
        before(:each) { subject.swap_source(activated_bridge, abridge_dup) }

        it { subject.source.should_not include(activated_bridge) }
        it { subject.source.should include(abridge_dup) }

        it_behaves_like "checks mob duplication"
      end

      describe "exnchange atoms" do
        shared_examples_for "check exchanges in result" do
          shared_examples_for "check atoms" do
            subject { atoms.first.map(&:first) + atoms.last.map(&:first) }
            it { should include(new_atom) }
            it { should_not include(old_atom) }
          end

          it_behaves_like "check atoms" do
            let(:atoms) { df_atom_map.changes.map(&:last) }
          end

          it_behaves_like "check atoms" do
            let(:atoms) { df_atom_map.full.map(&:last) }
          end
        end

        describe "#swap_atom" do
          let(:old_atom) { activated_bridge.atom(:ct) }
          let(:new_atom) { old_atom.dup }
          before(:each) do
            df_atom_map.swap_atom(activated_bridge, old_atom, new_atom)
          end

          it_behaves_like "check exchanges in result"
        end

        describe "#apply_relevants" do
          let(:old_atom) { activated_bridge.atom(:ct) }
          let(:new_atom) { incoherent_activated_cd }
          before(:each) do
            df_atom_map.apply_relevants(activated_bridge, old_atom, new_atom)
          end

          it { df_atom_map.products.first.atom(:cl).incoherent?.should be_true }
          it { df_atom_map.products.first.atom(:cr).incoherent?.should be_true }

          it_behaves_like "check exchanges in result"
        end
      end

      describe "#complex_source_spec_and_atom" do
        it { ma_atom_map.complex_source_spec_and_atom.
          should =~ [ma_source.first, c] }

        it { dm_atom_map.complex_source_spec_and_atom.
          should =~ [activated_methyl_on_bridge, activated_c] }
      end
    end

  end
end
