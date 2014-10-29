require 'spec_helper'

module VersatileDiamond
  module Mcs

    describe ManyToManyAlgorithm do
      describe '#self.map_to' do
        describe 'methyl deactivation' do
          let(:spec1) { dm_source.first }
          let(:spec2) { hydrogen_ion }
          let(:spec3) { dm_product.first }

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

          it_behaves_like :check_mapping_result do
            subject { described_class.map_to(mapping_result, dm_names_to_specs) }
          end
        end

        describe 'hydrogen migration' do
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
                [spec1.atom(:crb), spec3.atom(:crb)],
                [spec1.atom(:_cr0), spec3.atom(:_cr0)],
                [spec1.atom(:cr), spec3.atom(:cr)],
                [spec1.atom(:_cr1), spec3.atom(:_cr1)],
                [spec1.atom(:clb), spec3.atom(:clb)],
                [spec1.atom(:cl), spec3.atom(:cl)],
              ]],
              [[spec2, spec4], [
                [spec2.atom(:cr), spec4.atom(:cr)],
                [spec2.atom(:crb), spec4.atom(:crb)],
                [spec2.atom(:_cr0), spec4.atom(:_cr0)],
                [spec2.atom(:cl), spec4.atom(:cl)],
                [spec2.atom(:clb), spec4.atom(:clb)],
                [spec2.atom(:_cr1), spec4.atom(:_cr1)],
              ]],
            ]
          end

          it_behaves_like :check_mapping_result do
            subject { described_class.map_to(mapping_result, hm_names_to_specs) }
          end
        end
      end
    end

  end
end
