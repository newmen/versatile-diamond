require 'spec_helper'

module VersatileDiamond
  module Mcs

    describe ManyToOneAlgorithm, type: :mapping_algorithm do
      describe "#self.map_to" do
        subject { described_class.map_to(mapping_result) }

        describe "simple case" do
          describe "each atom has a copy" do
            let(:n1) { n.dup }
            let(:o1) { o.dup }

            let(:spec1) do
              s = Concepts::SurfaceSpec.new(:spec1, n: n, c: c)
              s.link(n, c, free_bond)
              Concepts::SpecificSpec.new(s, c: activated_c)
            end

            let(:spec2) do
              s = Concepts::SurfaceSpec.new(:spec2, o: o, c: c0)
              s.link(o, c0, free_bond)
              Concepts::SpecificSpec.new(s, c: activated_c0)
            end

            let(:spec3) do
              s = Concepts::SurfaceSpec.new(
                :spec3, n: n1, c1: c1, c2: c2, o: o1)
              s.link(n1, c1, free_bond)
              s.link(c1, c2, free_bond)
              s.link(o1, c2, free_bond)
              Concepts::SpecificSpec.new(s)
            end

            describe "forward" do
              # with default source and products sequence
              let(:changed) do
                [[[spec1, spec3],
                  [[activated_c, c1]]],
                [[spec2, spec3],
                  [[activated_c0, c2]]]]
              end
              let(:full) do
                [[[spec1, spec3], [
                  [n, n1], [activated_c, c1]
                ]],
                [[spec2, spec3], [
                  [activated_c0, c2], [o, o1]
                ]]]
              end

              it_behaves_like "check mapping result"
            end

            describe "reverse" do
              # override default source and products sequence
              let(:source) { [spec3] }
              let(:products) { [spec1, spec2] }
              let(:changed) do
                [[[spec3, spec1],
                  [[c1, activated_c]]],
                [[spec3, spec2],
                  [[c2, activated_c0]]]]
              end
              let(:full) do
                [[[spec3, spec1], [
                  [n1, n], [c1, activated_c]
                ]],
                [[spec3, spec2], [
                  [c2, activated_c0], [o1, o]
                ]]]
              end

              it_behaves_like "check mapping result"
            end
          end

          describe "not each atom has a copy" do
            let(:spec1) do
              s = Concepts::SurfaceSpec.new(:spec1, n: n, c: c)
              s.link(n, c, free_bond)
              Concepts::SpecificSpec.new(s, c: activated_c)
            end

            let(:spec2) do
              s = Concepts::SurfaceSpec.new(:spec2, o: o, c: c)
              s.link(o, c, free_bond)
              Concepts::SpecificSpec.new(s, c: activated_c)
            end

            let(:spec3) do
              s = Concepts::SurfaceSpec.new(:spec3, n: n, c1: c, c2: c1, o: o)
              s.link(n, c, free_bond)
              s.link(c, c1, free_bond)
              s.link(o, c1, free_bond)
              Concepts::SpecificSpec.new(s)
            end

            let(:changed) do
              [[[spec1, spec3],
                [[activated_c, c]]],
              [[spec2, spec3],
                [[activated_c, c1]]]]
            end
            let(:full) do
              [[[spec1, spec3], [
                [n, n], [activated_c, c]
              ]],
              [[spec2, spec3], [
                [activated_c, c1], [o, o]
              ]]]
            end

            it_behaves_like "check mapping result"
          end
        end

        describe "surface structures" do
          describe "methyl on bridge with bridge" do
            let(:spec1) { methyl_on_activated_bridge }
            let(:spec2) { activated_bridge }
            let(:spec3) { methyl_on_dimer }

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

            it_behaves_like "check mapping result"
          end

          describe "high bridge with bridge" do
            let(:spec1) { high_bridge }
            let(:spec2) { activated_bridge }
            let(:spec3) { right_activated_extended_bridge }

            let(:changed) do
              [
                # order of atoms is important
                [[spec1, spec3], [
                  [spec1.atom(:cm), spec3.atom(:ct)],
                  [spec1.atom(:cb), spec3.atom(:cr)],
                ]],
                [[spec2, spec3], [
                  [spec2.atom(:ct), spec3.atom(:cl)]
                ]]
              ]
            end
            let(:full) do
              [
                [[spec1, spec3], [
                  [spec1.atom(:cm), spec3.atom(:ct)],
                  [spec1.atom(:cb), spec3.atom(:cr)],
                  [spec1.atom(:cl), spec3.atom(:_cl1)],
                  [spec1.atom(:cr), spec3.atom(:_cr1)],
                ]],
                [[spec2, spec3], [
                  [spec2.atom(:ct), spec3.atom(:cl)],
                  [spec2.atom(:cl), spec3.atom(:_cl0)],
                  [spec2.atom(:cr), spec3.atom(:_cr0)],
                ]]
              ]
            end

            it_behaves_like "check mapping result"
          end

          describe "methyl on extended bridge" do
            let(:spec1) { activated_methyl_on_extended_bridge }
            let(:spec2) { activated_dimer }
            let(:spec3) { extended_dimer }

            let(:changed) do
              [
                [[spec1, spec3], [
                  [spec1.atom(:cm), spec3.atom(:cr)],
                  [spec1.atom(:cb), spec3.atom(:cl)],
                ]],
                [[spec2, spec3], [
                  [spec2.atom(:cl), spec3.atom(:_cr0)],
                  [spec2.atom(:cr), spec3.atom(:_cl1)],
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
                  [spec2.atom(:cl), spec3.atom(:_cr0)],
                  [spec2.atom(:_cl0), spec3.atom(:_cl2)],
                  [spec2.atom(:_cr1), spec3.atom(:_cr2)],
                  [spec2.atom(:cr), spec3.atom(:_cl1)],
                  [spec2.atom(:_cl1), spec3.atom(:_cl5)],
                  [spec2.atom(:_cr0), spec3.atom(:_cr5)],
                ]]
              ]
            end

            it_behaves_like "check mapping result"
          end
        end
      end
    end

  end
end
