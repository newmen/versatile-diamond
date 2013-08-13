require 'spec_helper'

module VersatileDiamond
  module Mcs

    describe AtomMapper do
      describe "#self.map" do
        describe "many to many" do
          it { described_class.map(
              [activated_bridge, methyl_on_bridge],
              [bridge, actived_methyl_on_bridge]
            ).should == [
              [[activated_bridge, bridge], [[activated_cd, cd]]],
              [[methyl_on_bridge, actived_methyl_on_bridge], [[c, activated_c]]]
            ] }
        end

        describe "many to one" do
          it { described_class.map(
              [activated_bridge, methyl_on_actived_bridge],
              [methyl_on_dimer]
            ).should == [
              [[methyl_on_actived_bridge, methyl_on_dimer],
                [[
                  methyl_on_bridge_base.atom(:cb),
                  methyl_on_dimer_base.atom(:cr)
                ]]],
              [[activated_bridge, methyl_on_dimer],
                [[
                  bridge_base.atom(:ct),
                  methyl_on_dimer_base.atom(:cl)
                ]]]
            ] }
        end
      end
    end

  end
end
