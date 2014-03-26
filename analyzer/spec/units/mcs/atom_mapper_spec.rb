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
              ).changes.should =~ [
                [[activated_bridge, bridge], [[activated_cd, cd]]],
                [[methyl_on_bridge, activated_methyl_on_bridge],
                  [[c, activated_c]]]
              ] }
          end

          describe "methyl activation" do
            it { ma_atom_map.changes.should =~ [
                [[ma_source.first, activated_methyl_on_bridge],
                  [[c, activated_c]]]
              ] }

            describe "methyl on bridge isn't specified" do
              before { ma_atom_map } # runs atom mapping
              it { methyl_on_bridge.atom(:cm).should be_a(Concepts::Atom) }
            end
          end
        end

        describe "many to one" do
          describe "dimer formation" do
            it { df_atom_map.changes.should =~ [
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
    end

  end
end
