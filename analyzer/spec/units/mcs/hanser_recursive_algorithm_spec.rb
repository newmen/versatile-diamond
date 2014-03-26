require 'spec_helper'

module VersatileDiamond
  module Mcs

    describe HanserRecursiveAlgorithm do
      let(:bridge_links) { bridge_base.links }
      let(:methyl_on_bridge_links) { methyl_on_bridge_base.links }
      let(:assoc) do
        AssocGraph.new(
          Graph.new(bridge_links), Graph.new(methyl_on_bridge_links))
      end

      describe "#self.contain?" do
        it { expect(described_class.contain?(methyl_on_bridge_links, bridge_links)).
          to be_true }
        it { expect(described_class.contain?(bridge_links, methyl_on_bridge_links)).
          to be_false }

        let(:methane_links) { methane_base.links }

        it { expect(described_class.contain?(bridge_links, methane_links)).
          to be_false }
        it { expect(described_class.contain?(methane_links, bridge_links)).
          to be_false }
        it { expect(described_class.contain?(methyl_on_bridge_links, methane_links)).
          to be_true }
        it { expect(described_class.contain?(methane_links, methyl_on_bridge_links)).
          to be_false }

        let(:methyl_on_dimer_links) { methyl_on_dimer_base.links }

        it { expect(described_class.contain?(
          methyl_on_dimer_links, bridge_links)).to be_true }
        it { expect(described_class.contain?(
          bridge_links, methyl_on_dimer_links)).to be_false }
        it { expect(described_class.contain?(
          methyl_on_dimer_links, methyl_on_bridge_links)).to be_true }
        it { expect(described_class.contain?(
          methyl_on_bridge_links, methyl_on_dimer_links)).to be_false }
        it { expect(described_class.contain?(
          methyl_on_dimer_links, methane_links)).to be_true }
        it { expect(described_class.contain?(
          methane_links, methyl_on_dimer_links)).to be_false }

        let(:high_bridge_links) { high_bridge_base.links }

        it { expect(described_class.contain?(
          high_bridge_links, methyl_on_bridge_links)).to be_true }

        describe "separated_multi_bond: true" do
          it { expect(described_class.contain?(
            high_bridge_links, methyl_on_bridge_links ,
            separated_multi_bond: true)).to be_false }
        end
      end

      describe "#self.first_interset" do
        subject { described_class.first_interset(assoc) }
        it { expect(subject.size).to eq(3) }
        it { expect(subject).to include(
            [bridge_base.atom(:ct), methyl_on_bridge_base.atom(:cb)],
            [bridge_base.atom(:cr), methyl_on_bridge_base.atom(:cr)],
            [bridge_base.atom(:cl), methyl_on_bridge_base.atom(:cl)]
          ) }
      end

      describe "#intersets" do
        subject { described_class.new(assoc).intersets }
        it { expect(subject.size).to eq(2) }
        it { expect(subject.first).to include(
            [bridge_base.atom(:ct), methyl_on_bridge_base.atom(:cb)],
            [bridge_base.atom(:cr), methyl_on_bridge_base.atom(:cr)],
            [bridge_base.atom(:cl), methyl_on_bridge_base.atom(:cl)]
          ) }
        it { expect(subject.last).to include(
            [bridge_base.atom(:ct), methyl_on_bridge_base.atom(:cb)],
            [bridge_base.atom(:cr), methyl_on_bridge_base.atom(:cl)],
            [bridge_base.atom(:cl), methyl_on_bridge_base.atom(:cr)]
          ) }
      end
    end

  end
end
