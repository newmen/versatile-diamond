require 'spec_helper'

module VersatileDiamond
  module Mcs

    describe ManyToOneAlgorithm do
      describe '#self.map_to' do
        subject { described_class.map_to(mapping_result) }

        describe 'simple case' do
          describe 'each atom has a copy' do
            let(:n1) { n.dup }
            let(:o1) { o.dup }

            let(:spec1) do
              s = Concepts::SurfaceSpec.new(:spec1, n: n, c: cd)
              s.link(n, cd, free_bond)
              Concepts::SpecificSpec.new(s, c: activated_cd)
            end

            let(:spec2) do
              s = Concepts::SurfaceSpec.new(:spec2, o: o, c: cd0)
              s.link(o, cd0, free_bond)
              Concepts::SpecificSpec.new(s, c: activated_cd0)
            end

            let(:spec3) do
              s = Concepts::SurfaceSpec.new(
                :spec3, n: n1, c1: cd1, c2: cd2, o: o1)
              s.link(n1, cd1, free_bond)
              s.link(cd1, cd2, bond_100_front)
              s.link(o1, cd2, free_bond)
              Concepts::SpecificSpec.new(s)
            end

            describe 'forward' do
              # with default source and products sequence
              let(:changed) do
                [
                  [[spec1, spec3], [[activated_cd, cd1]]],
                  [[spec2, spec3], [[activated_cd0, cd2]]]
                ]
              end
              let(:full) do
                [
                  [[spec1, spec3], [[activated_cd, cd1], [n, n1]]],
                  [[spec2, spec3], [[activated_cd0, cd2], [o, o1]]]
                ]
              end

              it_behaves_like :check_mapping_result
            end

            describe 'reverse' do
              # override default source and products sequence
              let(:source) { [spec3] }
              let(:products) { [spec1, spec2] }
              let(:changed) do
                [
                  [[spec3, spec1], [[cd1, activated_cd]]],
                  [[spec3, spec2], [[cd2, activated_cd0]]]
                ]
              end
              let(:full) do
                [
                  [[spec3, spec1], [[cd1, activated_cd], [n1, n]]],
                  [[spec3, spec2], [[cd2, activated_cd0], [o1, o]]]
                ]
              end

              it_behaves_like :check_mapping_result
            end
          end

          describe 'not each atom has a copy' do
            let(:spec1) do
              s = Concepts::SurfaceSpec.new(:spec1, n: n, c: cd)
              s.link(n, cd, free_bond)
              Concepts::SpecificSpec.new(s, c: activated_cd)
            end

            let(:spec2) do
              s = Concepts::SurfaceSpec.new(:spec2, o: o, c: cd)
              s.link(o, cd, free_bond)
              Concepts::SpecificSpec.new(s, c: activated_cd)
            end

            let(:spec3) do
              s = Concepts::SurfaceSpec.new(:spec3, n: n, c1: cd, c2: cd1, o: o)
              s.link(n, cd, free_bond)
              s.link(cd, cd1, bond_100_front)
              s.link(o, cd1, free_bond)
              Concepts::SpecificSpec.new(s)
            end

            let(:changed) do
              [
                [[spec1, spec3], [[activated_cd, cd]]],
                [[spec2, spec3], [[activated_cd, cd1]]]
              ]
            end
            let(:full) do
              [
                [[spec1, spec3], [[activated_cd, cd], [n, n]]],
                [[spec2, spec3], [[activated_cd, cd1], [o, o]]]
              ]
            end

            it_behaves_like :check_mapping_result
          end
        end

        describe 'surface structures' do
          describe 'methyl on bridge with bridge' do
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
                  [spec1.atom(:cb), spec3.atom(:cr)],
                  [spec1.atom(:cl), spec3.atom(:crb)],
                  [spec1.atom(:cr), spec3.atom(:_cr0)],
                  [spec1.atom(:cm), spec3.atom(:cm)],
                ]],
                [[spec2, spec3], [
                  [spec2.atom(:ct), spec3.atom(:cl)],
                  [spec2.atom(:cl), spec3.atom(:_cr1)],
                  [spec2.atom(:cr), spec3.atom(:clb)],
                ]]
              ]
            end

            it_behaves_like :check_mapping_result
          end

          describe 'high bridge with bridge' do
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
                  [spec1.atom(:cl), spec3.atom(:_cl1_)],
                  [spec1.atom(:cr), spec3.atom(:_cr1_)],
                ]],
                [[spec2, spec3], [
                  [spec2.atom(:ct), spec3.atom(:cl)],
                  [spec2.atom(:cl), spec3.atom(:_cl0_)],
                  [spec2.atom(:cr), spec3.atom(:_cr0_)],
                ]]
              ]
            end

            it_behaves_like :check_mapping_result
          end

          describe 'methyl on extended bridge' do
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
                  [spec2.atom(:cl), spec3.atom(:crb)],
                  [spec2.atom(:cr), spec3.atom(:_cr0)],
                ]]
              ]
            end
            let(:full) do
              [
                [[spec1, spec3], [
                  [spec1.atom(:cm), spec3.atom(:cr)],
                  [spec1.atom(:cb), spec3.atom(:cl)],
                  [spec1.atom(:cl), spec3.atom(:_cr1)],
                  [spec1.atom(:cr), spec3.atom(:clb)],
                  [spec1.atom(:_cl0_), spec3.atom(:_cl2_)],
                  [spec1.atom(:_cr0_), spec3.atom(:_cr4_)],
                  [spec1.atom(:_cl1_), spec3.atom(:_cl3_)],
                  [spec1.atom(:_cr1_), spec3.atom(:_cr5_)],
                ]],
                [[spec2, spec3], [
                  [spec2.atom(:cl), spec3.atom(:crb)],
                  [spec2.atom(:cr), spec3.atom(:_cr0)],
                  [spec2.atom(:clb), spec3.atom(:_cl0_)],
                  [spec2.atom(:_cr1), spec3.atom(:_cr2_)],
                  [spec2.atom(:crb), spec3.atom(:_cl1_)],
                  [spec2.atom(:_cr0), spec3.atom(:_cr3_)],
                ]]
              ]
            end

            it_behaves_like :check_mapping_result
          end

          describe 'migration methyl to gap' do
            let(:spec1) { extra_activated_methyl_on_bridge }
            let(:spec2) { right_activated_bridge.dup }
            let(:spec3) { right_activated_bridge.dup }
            let(:spec4) { horizont_extended_dimer }

            let(:source) { [spec1, spec2, spec3] }
            let(:products) { [spec4] }

            let(:changed) do
              [
                [[spec1, spec4], [
                  [spec1.atom(:cm), spec4.atom(:cr)],
                  [spec1.atom(:cb), spec4.atom(:cl)],
                ]],
                [[spec2, spec4], [
                  [spec2.atom(:cr), spec4.atom(:crb)],
                ]],
                [[spec3, spec4], [
                  [spec3.atom(:cr), spec4.atom(:_cr0)],
                ]]
              ]
            end
            let(:full) do
              [
                [[spec1, spec4], [
                  [spec1.atom(:cm), spec4.atom(:cr)],
                  [spec1.atom(:cb), spec4.atom(:cl)],
                  [spec1.atom(:cl), spec4.atom(:_cl0)],
                  [spec1.atom(:cr), spec4.atom(:_cr1)],
                ]],
                [[spec2, spec4], [
                  [spec2.atom(:cr), spec4.atom(:crb)],
                  [spec2.atom(:ct), spec4.atom(:clht)],
                  [spec2.atom(:cl), spec4.atom(:clhb)],
                ]],
                [[spec3, spec4], [
                  [spec3.atom(:cr), spec4.atom(:_cr0)],
                  [spec3.atom(:ct), spec4.atom(:crht)],
                  [spec3.atom(:cl), spec4.atom(:crhb)],
                ]],
              ]
            end

            it_behaves_like :check_mapping_result
          end

          describe 'next level dimer formation over activated dimer' do
            let(:ab) { activated_bridge }
            let(:ead_n_eamob) { ea_dimer_near_ea_mob }
            let(:tl_bot_ad) { two_next_level_dimers_with_bottom_activated }

            let(:source) { [ab, ead_n_eamob] }
            let(:products) { [tl_bot_ad] }

            let(:changed) do
              [
                [[ab, tl_bot_ad], [
                  [ab.atom(:ct), tl_bot_ad.atom(:cbt)]
                ]],
                [[ead_n_eamob, tl_bot_ad], [
                  [ead_n_eamob.atom(:cm), tl_bot_ad.atom(:ctr)],
                  [ead_n_eamob.atom(:ctl), tl_bot_ad.atom(:ctl)],
                  [ead_n_eamob.atom(:cdd), tl_bot_ad.atom(:cdd)]
                ]]
              ]
            end
            let(:full) do
              [
                [[ab, tl_bot_ad], [
                  [ab.atom(:ct), tl_bot_ad.atom(:cbt)],
                  [ab.atom(:cr), tl_bot_ad.atom(:clr)],
                  [ab.atom(:cl), tl_bot_ad.atom(:cll)]
                ]],
                [[ead_n_eamob, tl_bot_ad], [
                  [ead_n_eamob.atom(:cm), tl_bot_ad.atom(:ctr)],
                  [ead_n_eamob.atom(:ctl), tl_bot_ad.atom(:ctl)],
                  [ead_n_eamob.atom(:cmr), tl_bot_ad.atom(:cmr)],
                  [ead_n_eamob.atom(:cml), tl_bot_ad.atom(:cml)],
                  [ead_n_eamob.atom(:cdd), tl_bot_ad.atom(:cdd)],
                  [ead_n_eamob.atom(:cdr), tl_bot_ad.atom(:cdr)],
                  [ead_n_eamob.atom(:clb), tl_bot_ad.atom(:clb)],
                  [ead_n_eamob.atom(:_cr1), tl_bot_ad.atom(:_cr1)],
                  [ead_n_eamob.atom(:crb), tl_bot_ad.atom(:crb)],
                  [ead_n_eamob.atom(:_cr0), tl_bot_ad.atom(:_cr0)]
                ]]
              ]
            end

            it_behaves_like :check_mapping_result
          end
        end
      end
    end

  end
end
