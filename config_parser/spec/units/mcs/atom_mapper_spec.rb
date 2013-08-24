require 'spec_helper'

module VersatileDiamond
  module Mcs

    describe AtomMapper do
      describe "#self.map" do
        describe "many to many" do
          describe "bridge hydrogen migration" do
            it { described_class.map(
                [activated_bridge, methyl_on_bridge],
                [bridge, activated_methyl_on_bridge],
                {
                  source: [[:b, activated_bridge], [:mob, methyl_on_bridge]],
                  products: [[:b, bridge], [:mob, activated_methyl_on_bridge]]
                }
              ).should == [
                [[activated_bridge, bridge], [[activated_cd, cd]]],
                [[methyl_on_bridge, activated_methyl_on_bridge],
                  [[c, activated_c]]]
              ] }
          end

          describe "methyl activation" do
            it { ma_atom_map.should == [
                [[ma_source.first, activated_methyl_on_bridge],
                  [[c, activated_c]]]
              ] }

            describe "methyl on bridge isn't specified" do
              before { ma_atom_map } # runs atom mapping
              it { methyl_on_bridge.atom(:cm).should be_a(Concepts::Atom) }
            end
          end

          describe "dimer hydrogen migration" do
            it { hm_atom_map.should == [
                [[methyl_on_dimer, activated_methyl_on_dimer],
                  [[c, activated_c]]],
                [[activated_dimer, dimer], [[activated_cd, dimer.atom(:cr)]]]
              ] }
          end
        end

        describe "many to one" do
          describe "concrete dimer formation" do
            it { described_class.map(
                [activated_bridge, methyl_on_activated_bridge],
                [methyl_on_dimer],
                {
                  source: [
                    [:b, activated_bridge],
                    [:mob, methyl_on_activated_bridge]],
                  products: [[:mod, methyl_on_dimer]]
                }
              ).should == [
                [[methyl_on_activated_bridge, methyl_on_dimer],
                  [[
                    methyl_on_activated_bridge.atom(:cb),
                    methyl_on_dimer.atom(:cr)
                  ]]],
                [[activated_bridge, methyl_on_dimer],
                  [[
                    activated_bridge.atom(:ct),
                    methyl_on_dimer.atom(:cl)
                  ]]]
              ] }
          end

          describe "methyl deactivation" do
            it { dm_atom_map.should == [
                [[activated_methyl_on_bridge, methyl_on_bridge],
                  [[activated_c, c]]]
              ] }
          end

          describe "methyl desorption" do
            it { md_atom_map.should == [
                [[methyl_on_bridge, activated_bridge],
                  [[methyl_on_bridge.atom(:cb), activated_cd]]],
                [[methyl_on_bridge, methyl],
                  [[methyl_on_bridge.atom(:cm), activated_c]]]
              ] }

            describe "methyl on bridge is incoherent and unfixed" do
              before(:each) { md_atom_map } # runs atom mapping
              it { methyl_on_bridge.atom(:cm).incoherent?.should be_true }
              it { methyl_on_bridge.atom(:cm).unfixed?.should be_true }
            end
          end

          describe "dimer formation" do
            it { df_atom_map.should == [
                [[activated_bridge, dimer_dup_ff],
                  [[activated_cd, dimer_dup_ff.atom(:cr)]]],
                [[activated_incoherent_bridge, dimer_dup_ff],
                  [[activated_incoherent_cd, dimer_dup_ff.atom(:cl)]]]
              ] }

            describe "correspond dimer atom is incoherent" do
              before(:each) { df_atom_map } # runs atom mapping
              it { dimer_dup_ff.atom(:cl).incoherent?.should be_true }
              it { dimer_dup_ff.atom(:cr).should be_a(Concepts::Atom) }
            end
          end
        end
      end

      describe "#self.reverse" do
        it { described_class.reverse(hm_atom_map).should == [
            [[activated_methyl_on_dimer, methyl_on_dimer], [[activated_c, c]]],
            [[dimer, activated_dimer], [[dimer.atom(:cr), activated_cd]]]
          ] }

        it { described_class.reverse(md_atom_map).should == [
            [[activated_bridge, methyl_on_bridge],
              [[activated_cd, methyl_on_bridge.atom(:cb)]]],
            [[methyl, methyl_on_bridge],
              [[activated_c, methyl_on_bridge.atom(:cm)]]]
          ] }

        describe "dimer formation" do
          before { df_atom_map } # runs atom mapping

          it { described_class.reverse(df_atom_map).should == [
              [[dimer_dup_ff, activated_bridge],
                [[dimer_dup_ff.atom(:cr), activated_cd]]],
              [[dimer_dup_ff, activated_incoherent_bridge],
                [[dimer_dup_ff.atom(:cl), activated_incoherent_cd]]]
            ] }
        end
      end
    end

  end
end
