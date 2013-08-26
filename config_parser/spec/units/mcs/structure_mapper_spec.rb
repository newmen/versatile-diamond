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

          it "map and associate all" do
            m = method(:associate)
            described_class.map(
              source_links, product_links, &m).first.should == full
          end

          it "map and associate changed" do
            m = method(:associate)
            described_class.map(
              source_links, product_links, &m).last.should == changed
          end
        end

        let(:source) { [spec1, spec2] }
        let(:product) { [spec3] }

        describe "simple case" do
          describe "each atom has a copy" do
            let(:n1) { n.dup }
            let(:o1) { o.dup }

            let(:spec1) do
              s = Concepts::Spec.new(:spec1, n: n, c: c)
              s.link(n, c, free_bond); s
            end

            let(:spec2) do
              s = Concepts::Spec.new(:spec2, o: o, c: c0)
              s.link(o, c0, free_bond); s
            end

            let(:spec3) do
              s = Concepts::Spec.new(:spec3, n: n1, c1: c1, c2: c2, o: o1)
              s.link(n1, c1, free_bond)
              s.link(c1, c2, free_bond)
              s.link(o1, c2, free_bond); s
            end

            describe "forward" do
              # with default source and products sequence
              let(:changed) do
                [[[spec1, spec3], [[c, c1]]], [[spec2, spec3], [[c0, c2]]]]
              end
              let(:full) do
                [[[spec1, spec3], [[n, n1], [c, c1]]],
                [[spec2, spec3], [[c0, c2], [o, o1]]]]
              end

              it_behaves_like "two to one"
            end

            describe "reverse" do
              # override default source and products sequence
              let(:source) { [spec3] }
              let(:product) { [spec1, spec2] }
              let(:changed) do
                [[[spec3, spec1], [[c1, c]]], [[spec3, spec2], [[c2, c0]]]]
              end
              let(:full) do
                [[[spec3, spec1], [[n1, n], [c1, c]]],
                [[spec3, spec2], [[c2, c0], [o1, o]]]]
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

            let(:changed) do
              [[[spec1, spec3], [[c, c]]], [[spec2, spec3], [[c, c1]]]]
            end
            let(:full) do
              [[[spec1, spec3], [[n, n], [c, c]]],
              [[spec2, spec3], [[c, c1], [o, o]]]]
            end

            it_behaves_like "two to one"
          end
        end

        describe "surface structures" do
          describe "bridge with methane" do
            let(:spec1) { bridge_base }
            let(:spec2) { methane_base }
            let(:spec3) { methyl_on_bridge_base }

            let(:changed) do
              [
                [[spec1, spec3], [[spec1.atom(:ct), spec3.atom(:cb)]]],
                [[spec2, spec3], [[spec2.atom(:c), spec3.atom(:cm)]]]
              ]
            end
            let(:full) do
              [
                [[spec1, spec3], [
                  [spec1.atom(:ct), spec3.atom(:cb)],
                  [spec1.atom(:cl), spec3.atom(:cl)],
                  [spec1.atom(:cr), spec3.atom(:cr)],
                ]],
                [[spec2, spec3], [
                  [spec2.atom(:c), spec3.atom(:cm)]
                ]]
              ]
            end

            it_behaves_like "two to one"
          end

          describe "methyl on bridge with bridge" do
            let(:spec1) { methyl_on_bridge_base }
            let(:spec2) { bridge_base }
            let(:spec3) { methyl_on_dimer_base }

            let(:changed) do
              [
                [[spec1, spec3], [[spec1.atom(:cb), spec3.atom(:cr)]]],
                [[spec2, spec3], [[spec2.atom(:ct), spec3.atom(:cl)]]]
              ]
            end
            let(:full) do
              [
                [[spec1, spec3], [
                  [spec1.atom(:cm), spec3.atom(:cm)],
                  [spec1.atom(:cb), spec3.atom(:cr)],
                  [spec1.atom(:cl), spec3.atom(:_cr0)],
                  [spec1.atom(:cr), spec3.atom(:_cl1)]
                ]],
                [[spec2, spec3], [
                  [spec2.atom(:cl), spec3.atom(:_cl0)],
                  [spec2.atom(:cr), spec3.atom(:_cr1)],
                  [spec2.atom(:ct), spec3.atom(:cl)]
                ]]
              ]
            end

            it_behaves_like "two to one"
          end

          describe "high bridge_base with bridge_base" do
            let(:spec1) { high_bridge_base }
            let(:spec2) { bridge_base }
            let(:spec3) { extended_bridge_base }

            let(:changed) do
              [
                # order of atoms is important
                [[spec1, spec3], [
                  [spec1.atom(:cm), spec3.atom(:ct)],
                  [spec1.atom(:cb), spec3.atom(:cl)]
                ]],
                [[spec2, spec3], [[spec2.atom(:ct), spec3.atom(:cr)]]]
              ]
            end
            let(:full) do
              [
                [[spec1, spec3], [
                  [spec1.atom(:cm), spec3.atom(:ct)],
                  [spec1.atom(:cb), spec3.atom(:cl)],
                  [spec1.atom(:cl), spec3.atom(:_cl0)],
                  [spec1.atom(:cr), spec3.atom(:_cr0)],
                ]],
                [[spec2, spec3], [
                  [spec2.atom(:ct), spec3.atom(:cr)],
                  [spec2.atom(:cl), spec3.atom(:_cl1)],
                  [spec2.atom(:cr), spec3.atom(:_cr1)]
                ]]
              ]
            end

            it_behaves_like "two to one"
          end

          describe "methyl on extended bridge_base " do
            let(:spec1) { methyl_on_extended_bridge_base }
            let(:spec2) { dimer_base }
            let(:spec3) { extended_dimer_base }

            let(:changed) do
              [
                [[spec1, spec3], [
                  [spec1.atom(:cm), spec3.atom(:cr)],
                  [spec1.atom(:cb), spec3.atom(:cl)]
                ]],
                [[spec2, spec3], [
                  [spec2.atom(:cl), spec3.atom(:_cl1)],
                  [spec2.atom(:cr), spec3.atom(:_cr0)]
                ]]
              ]
            end
            let(:full) do
              [
                [[spec1, spec3], [
                  [spec1.atom(:cm), spec3.atom(:cr)],
                  [spec1.atom(:cb), spec3.atom(:cl)],
                  [spec1.atom(:cl), spec3.atom(:_cl0)],
                  [spec1.atom(:cr), spec3.atom(:_cr1)],
                  [spec1.atom(:_cl0), spec3.atom(:_cl3)],
                  [spec1.atom(:_cr0), spec3.atom(:_cr3)],
                  [spec1.atom(:_cl1), spec3.atom(:_cl4)],
                  [spec1.atom(:_cr1), spec3.atom(:_cr4)],
                ]],
                [[spec2, spec3], [
                  [spec2.atom(:cr), spec3.atom(:_cr0)],
                  [spec2.atom(:_cl1), spec3.atom(:_cl2)],
                  [spec2.atom(:_cr0), spec3.atom(:_cr2)],
                  [spec2.atom(:cl), spec3.atom(:_cl1)],
                  [spec2.atom(:_cl0), spec3.atom(:_cl5)],
                  [spec2.atom(:_cr1), spec3.atom(:_cr5)],
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
