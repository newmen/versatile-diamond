require 'spec_helper'

module VersatileDiamond
  module Mcs

    describe ManyToManyAlgorithm, type: :mapping_algorithm do
      describe "#self.map_to" do
        describe "methyl deactivation" do
          let(:spec1) { activated_methyl_on_bridge }
          let(:spec2) { hydrogen_ion }
          let(:spec3) { methyl_on_bridge }

          let(:changed) do
            [
              [[spec1, spec3], [[spec1.atom(:cm), spec3.atom(:cm)]]],
            ]
          end
          let(:full) do
            [
              [[spec1, spec3], [
                [spec1.atom(:cm), spec3.atom(:cm)],
                [spec1.atom(:cb), spec3.atom(:cb)],
                [spec1.atom(:cl), spec3.atom(:cl)],
                [spec1.atom(:cr), spec3.atom(:cr)],
              ]],
            ]
          end

          it_behaves_like "check mapping result" do
            subject { described_class.map_to(
              mapping_result, dm_names_to_specs) }
          end
        end

        describe "hydrogen migration" do
          let(:spec1) { methyl_on_dimer }
          let(:spec2) { activated_dimer }
          let(:spec3) { activated_methyl_on_dimer }
          let(:spec4) { dimer }
          let(:products) { [activated_methyl_on_dimer, dimer] }

          let(:changed) do
            [
              [[spec1, spec3], [[spec1.atom(:cm), spec3.atom(:cm)]]],
              [[spec2, spec4], [[spec2.atom(:cr), spec4.atom(:cr)]]],
            ]
          end
          let(:full) do
            [
              [[spec1, spec3], [
                [spec1.atom(:cm), spec3.atom(:cm)],
                [spec1.atom(:_cr0), spec3.atom(:_cr0)],
                [spec1.atom(:cr), spec3.atom(:cr)],
                [spec1.atom(:_cl0), spec3.atom(:_cl0)],
                [spec1.atom(:_cr1), spec3.atom(:_cr1)],
                [spec1.atom(:_cl1), spec3.atom(:_cl1)],
                [spec1.atom(:cl), spec3.atom(:cl)],
              ]],
              [[spec2, spec4], [
                [spec2.atom(:cr), spec4.atom(:cr)],
                [spec2.atom(:_cl1), spec4.atom(:_cl1)],
                [spec2.atom(:_cr0), spec4.atom(:_cr0)],
                [spec2.atom(:cl), spec4.atom(:cl)],
                [spec2.atom(:_cl0), spec4.atom(:_cl0)],
                [spec2.atom(:_cr1), spec4.atom(:_cr1)],
              ]],
            ]
          end

          it_behaves_like "check mapping result" do
            subject { described_class.map_to(
              mapping_result, hm_names_to_specs) }
          end
        end
      end
    end

  end
end
