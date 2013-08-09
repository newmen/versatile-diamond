require 'spec_helper'

module VersatileDiamond
  module Mcs

    describe StructureMapper do
      describe "#self.map" do
        shared_examples "two to one" do
          def associate(links1, links2, atoms1, atoms2)
            [[links_to_source[links1], links_to_product[links2]],
              atoms1.zip(atoms2)]
          end

          %w(source product).each do |type|
            let(:"#{type}_links") { send(type).map(&:links) }
            let(:"links_to_#{type}") do
              Hash[send("#{type}_links").zip(send(type))]
            end
          end

          it "map and associate" do
            m = method(:associate)
            described_class.map(
              source_links, product_links, &m).should == result
          end
        end

        let(:source) { [spec1, spec2] }
        let(:product) { [spec3] }

        let(:free_bond) { Concepts::Bond[face: nil, dir: nil] }
        let(:c) { Concepts::Atom.new('C', 4) }

        describe "simple case" do
          3.times { |i| let("c#{i}".to_sym) { c.dup } }
          let(:n) { Concepts::Atom.new('N', 3) }
          let(:o) { Concepts::Atom.new('O', 2) }

          describe "each atom has a copy" do
            let(:spec1) do
              s = Concepts::Spec.new(:spec1, n: n, c: c)
              s.link(n, c, free_bond); s
            end

            let(:spec2) do
              s = Concepts::Spec.new(:spec2, o: o, c: c0)
              s.link(o, c0, free_bond); s
            end

            let(:spec3) do
              n1, o1 = n.dup, o.dup
              s = Concepts::Spec.new(:spec3, n: n1, c1: c1, c2: c2, o: o1)
              s.link(n1, c1, free_bond)
              s.link(c1, c2, free_bond)
              s.link(o1, c2, free_bond); s
            end

            describe "forward" do
              # with default source and products sequence
              let(:result) do
                [[[spec1, spec3], [[c, c1]]], [[spec2, spec3], [[c0, c2]]]]
              end

              it_behaves_like "two to one"
            end

            describe "reverse" do
              # override default source and products sequence
              let(:source) { [spec3] }
              let(:product) { [spec1, spec2] }
              let(:result) do
                [[[spec3, spec1], [[c1, c]]], [[spec3, spec2], [[c2, c0]]]]
              end

              it_behaves_like "two to one"
            end
          end

          describe "not each atom has a copy" do
            let(:spec1) do
              s = Concepts::Spec.new(:spec1, n: n, c: c)
              s.link(n, c, free_bond); s
            end

            let(:spec2) do
              s = Concepts::Spec.new(:spec2, o: o, c: c)
              s.link(o, c, free_bond); s
            end

            let(:spec3) do
              s = Concepts::Spec.new(:spec3, n: n, c1: c, c2: c1, o: o)
              s.link(n, c, free_bond)
              s.link(c, c1, free_bond)
              s.link(o, c1, free_bond); s
            end

            let(:result) do
              [[[spec1, spec3], [[c, c]]], [[spec2, spec3], [[c, c1]]]]
            end

            it_behaves_like "two to one"
          end
        end

        describe "surface structures" do
          let(:bond_110) { Concepts::Bond[face: 110, dir: :front] }
          let(:bond_100) { Concepts::Bond[face: 100, dir: :front] }
          let(:position_100) { Concepts::Position[face: 100, dir: :front] }

          let(:lattice) { Concepts::Lattice.new(:d, 'Diamond') }
          14.times do |i| # 14 instances of diamond latticed carbon atoms
            let(:"c#{i}") do
              cd = c.dup
              cd.lattice = lattice; cd
            end
          end

          let(:methane) { Concepts::Spec.new(:methane, c: c) }

          let(:bridge) do
            s = Concepts::Spec.new(:bridge, ct: c0, cr: c1, cl: c2)
            s.link(c0, c1, bond_110)
            s.link(c0, c2, bond_110)
            s.link(c1, c2, position_100); s
          end

          let(:methyl_on_bridge) do
            s = Concepts::Spec.new(:methyl_on_bridge,
              cm: c, cb: c0, cr: c1, cl: c2)

            s.link(c, c0, free_bond)
            s.link(c0, c1, bond_110)
            s.link(c0, c2, bond_110)
            s.link(c1, c2, position_100); s
          end

          describe "bridge with methane" do
            let(:spec1) { bridge }
            let(:spec2) { methane }
            let(:spec3) { methyl_on_bridge }

            let(:result) do
              [[[spec1, spec3], [[c0, c0]]], [[spec2, spec3], [[c, c]]]]
            end

            it_behaves_like "two to one"
          end

          let(:methyl_on_dimer) do
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

          describe "methyl on bridge with bridge" do
            let(:spec1) { methyl_on_bridge }
            let(:spec2) { bridge }
            let(:spec3) { methyl_on_dimer }

            let(:result) do
              [[[spec1, spec3], [[c0, c0]]], [[spec2, spec3], [[c0, c3]]]]
            end

            it_behaves_like "two to one"
          end

          let(:high_bridge) do
            s = Concepts::Spec.new(:high_bridge, cm: c, cb: c0, cr: c1, cl: c2)

            s.link(c, c0, free_bond)
            s.link(c, c0, free_bond)
            s.link(c0, c1, bond_110)
            s.link(c0, c2, bond_110)
            s.link(c1, c2, position_100); s
          end

          let(:extended_bridge) do
            s = Concepts::Spec.new(:extended_bridge,
              ct: c6, cr: c1, crr: c0, crl: c2, cl: c4, clr: c3, cll: c5)

            s.link(c1, c0, bond_110)
            s.link(c1, c2, bond_110)
            s.link(c0, c2, position_100)
            s.link(c4, c3, bond_110)
            s.link(c4, c5, bond_110)
            s.link(c3, c5, position_100)
            s.link(c6, c1, bond_110)
            s.link(c6, c4, bond_110)
            s.link(c1, c4, position_100); s
          end

          describe "high bridge with bridge" do
            let(:spec1) { high_bridge }
            let(:spec2) { bridge }
            let(:spec3) { extended_bridge }

            let(:result) do
              [
                # order of atoms is important
                [[spec1, spec3], [[c, c6], [c0, c1]]],
                [[spec2, spec3], [[c0, c4]]]
              ]
            end

            it_behaves_like "two to one"
          end

          let(:methyl_on_extended_bridge) do
            s = Concepts::Spec.new(:methyl_on_extended_bridge,
              cm: c, cb: c6,
              cr: c3, crr: c1, crl: c5,
              cl: c2, clr: c0, cll: c4)

            s.link(c, c6, free_bond)
            s.link(c6, c2, bond_110)
            s.link(c6, c3, bond_110)
            s.link(c2, c3, position_100)
            s.link(c2, c0, bond_110)
            s.link(c2, c4, bond_110)
            s.link(c0, c4, position_100)
            s.link(c3, c1, bond_110)
            s.link(c3, c5, bond_110)
            s.link(c1, c5, position_100); s
          end

          let(:dimer) do
            s = Concepts::Spec.new(:dimer,
              cr: c2, crr: c0, crl: c4, cl: c3, clr: c1, cll: c5)

            s.link(c2, c0, bond_110)
            s.link(c2, c4, bond_110)
            s.link(c0, c4, position_100)
            s.link(c3, c1, bond_110)
            s.link(c3, c5, bond_110)
            s.link(c1, c5, position_100)
            s.link(c2, c3, position_100); s
          end

          let(:extended_dimer) do
            s = Concepts::Spec.new(:dimer,
              cr: c11, crr: c3, crl: c2,
                crrr: c5, crrl: c1, crlr: c4, crll: c0,
              cl: c10, clr: c7, cll: c6,
                clrr: c9, clrl: c13, cllr: c8, clll: c12)
            # the atoms c0 and c8, c1 and c9 originaly is the same by diamond
            # crystall lattice

            s.link(c10, c11, bond_100)
            s.link(c10, c6, bond_110)
            s.link(c10, c7, bond_110)
            s.link(c6, c7, position_100)
            s.link(c6, c8, bond_110)
            s.link(c6, c12, bond_110)
            s.link(c8, c12, position_100)
            s.link(c7, c9, bond_110)
            s.link(c7, c13, bond_110)
            s.link(c9, c13, position_100)
            s.link(c11, c2, bond_110)
            s.link(c11, c3, bond_110)
            s.link(c2, c3, position_100)
            s.link(c2, c0, bond_110)
            s.link(c2, c4, bond_110)
            s.link(c0, c4, position_100)
            s.link(c3, c1, bond_110)
            s.link(c3, c5, bond_110)
            s.link(c1, c5, position_100); s
          end


          describe "methyl on extended bridge " do
            let(:spec1) { methyl_on_extended_bridge }
            let(:spec2) { dimer }
            let(:spec3) { extended_dimer }

            let(:result) do
              [
                # order of atoms is important because algorithm use the first
                # interset
                [[spec1, spec3], [[c, c11], [c6, c10]]],
                [[spec2, spec3], [[c3, c2], [c2, c3]]]
              ]
            end

            it_behaves_like "two to one"
          end
        end
      end
    end

  end
end
