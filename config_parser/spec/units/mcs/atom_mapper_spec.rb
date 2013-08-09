require 'spec_helper'

module VersatileDiamond
  module Mcs

    describe AtomMapper do
      describe "#self.map" do
        let(:free_bond) { Concepts::Bond[face: nil, dir: nil] }
        let(:bond_110) { Concepts::Bond[face: 110, dir: :front] }
        let(:bond_100) { Concepts::Bond[face: 100, dir: :front] }
        let(:position_100) { Concepts::Position[face: 100, dir: :front] }

        let(:lattice) { Concepts::Lattice.new(:d, 'Diamond') }
        let(:c) { Concepts::Atom.new('C', 4) }
        6.times do |i|
          let(:"c#{i}") do
            cd = c.dup
            cd.lattice = lattice; cd
          end
        end

        let(:c_actived) do
          a = Concepts::SpecificAtom.new(c.dup)
          a.active!; a
        end
        let(:c0_actived) do
          a = Concepts::SpecificAtom.new(c0.dup)
          a.active!; a
        end

        let(:base_bridge) do
          s = Concepts::Spec.new(:bridge, ct: c0, cr: c1, cl: c2)
          s.link(c0, c1, bond_110)
          s.link(c0, c2, bond_110)
          s.link(c1, c2, position_100); s
        end
        let(:bridge) { Concepts::SpecificSpec.new(base_bridge) }
        let(:actived_bridge) do
          Concepts::SpecificSpec.new(base_bridge, ct: c0_actived)
        end

        let(:base_methyl_on_bridge) do
          s = Concepts::Spec.new(:methyl_on_bridge,
            cm: c, cb: c0, cr: c1, cl: c2)

          s.link(c, c0, free_bond)
          s.link(c0, c1, bond_110)
          s.link(c0, c2, bond_110)
          s.link(c1, c2, position_100); s
        end
        let(:methyl_on_bridge) do
          Concepts::SpecificSpec.new(base_methyl_on_bridge)
        end
        let(:actived_methyl_on_bridge) do
          Concepts::SpecificSpec.new(base_methyl_on_bridge, cm: c_actived)
        end

        describe "many to many" do
          it { described_class.map(
              [actived_bridge, methyl_on_bridge],
              [bridge, actived_methyl_on_bridge]
            ).should == [
              [[actived_bridge, bridge], [[c0_actived, c0]]],
              [[methyl_on_bridge, actived_methyl_on_bridge], [[c, c_actived]]]
            ] }
        end

        describe "many to one" do
          let(:methyl_on_actived_bridge) do
            Concepts::SpecificSpec.new(base_methyl_on_bridge, cb: c0_actived)
          end

          let(:base_methyl_on_dimer) do
            s = Concepts::Spec.new(:methyl_on_dimer,
              cm: c, cr: c0, crr: c1, crl: c2, cl: c3, clr: c4, cll: c5)

            s.link(c, c0, free_bond)
            s.link(c0, c1, bond_110)
            s.link(c0, c2, bond_110)
            s.link(c1, c2, position_100)
            s.link(c0, c3, bond_100)
            s.link(c3, c4, bond_110)
            s.link(c3, c5, bond_110)
            s.link(c4, c5, position_100); s
          end
          let(:methyl_on_dimer) do
            Concepts::SpecificSpec.new(base_methyl_on_dimer)
          end

          it { described_class.map(
              [actived_bridge, methyl_on_actived_bridge],
              [methyl_on_dimer]
            ).should == [
              [[methyl_on_actived_bridge, methyl_on_dimer], [[c0, c0]]],
              [[actived_bridge, methyl_on_dimer], [[c0, c3]]]
            ] }
        end
      end
    end

  end
end
