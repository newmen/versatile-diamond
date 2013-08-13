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

        describe "simple case" do
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
          describe "bridge with methane" do
            let(:spec1) { bridge_base }
            let(:spec2) { methane_base }
            let(:spec3) { methyl_on_bridge_base }

            let(:result) do
              [
                [[spec1, spec3], [[spec1.atom(:ct), spec3.atom(:cb)]]],
                [[spec2, spec3], [[spec2.atom(:c), spec3.atom(:cm)]]]
              ]
            end

            it_behaves_like "two to one"
          end

          describe "methyl on bridge with bridge" do
            let(:spec1) { methyl_on_bridge_base }
            let(:spec2) { bridge_base }
            let(:spec3) { methyl_on_dimer_base }

            let(:result) do
              [
                [[spec1, spec3], [[spec1.atom(:cb), spec3.atom(:cr)]]],
                [[spec2, spec3], [[spec2.atom(:ct), spec3.atom(:cl)]]]
              ]
            end

            it_behaves_like "two to one"
          end

          describe "high bridge_base with bridge_base" do
            let(:spec1) { high_bridge_base }
            let(:spec2) { bridge_base }
            let(:spec3) { extended_bridge_base }

            let(:result) do
              [
                # order of atoms is important
                [[spec1, spec3], [
                  [spec1.atom(:cm), spec3.atom(:ct)],
                  [spec1.atom(:cb), spec3.atom(:cl)]
                ]],
                [[spec2, spec3], [[spec2.atom(:ct), spec3.atom(:cr)]]]
              ]
            end

            it_behaves_like "two to one"
          end

          describe "methyl on extended bridge_base " do
            let(:spec1) { methyl_on_extended_bridge_base }
            let(:spec2) { dimer_base }
            let(:spec3) { extended_dimer_base }

            let(:result) do
              [
                # order of atoms is important because algorithm use the first
                # interset
                [[spec1, spec3], [
                  [spec1.atom(:cm), spec3.atom(:cr)],
                  [spec1.atom(:cb), spec3.atom(:cl)]
                ]],
                [[spec2, spec3], [
                  [spec2.atom(:cl), spec3.atom(:_cl1)], # last keyname
                  # characterized by the absorption of two consecutive bridges
                  [spec2.atom(:cr), spec3.atom(:_cr0)]
                ]]
              ]
            end

            it_behaves_like "two to one"
          end
        end
      end
    end

  end
end
