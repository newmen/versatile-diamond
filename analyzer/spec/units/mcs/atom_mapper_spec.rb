require 'spec_helper'

module VersatileDiamond
  module Mcs

    describe AtomMapper do
      describe '#self.map' do
        describe 'many to many' do
          describe 'bridge hydrogen migration' do
            it { expect(described_class.map(
                [activated_bridge, methyl_on_bridge],
                [bridge, activated_methyl_on_bridge],
                {
                  source: [[:b, activated_bridge], [:mob, methyl_on_bridge]],
                  products: [[:b, bridge], [:mob, activated_methyl_on_bridge]]
                }
              ).changes).to match_array([
                [[activated_bridge, bridge], [[activated_cd, cd]]],
                [[methyl_on_bridge, activated_methyl_on_bridge],
                  [[c, activated_c]]]
              ]) }
          end

          describe 'methyl activation' do
            let(:ma_s) { ma_source.first }
            let(:ma_p) { ma_products.first }

            it { expect(ma_atom_map.changes).to match_array([
                [[ma_s, ma_p], [[ma_s.atom(:cm), ma_p.atom(:cm)]]]
              ]) }

            describe "methyl on bridge isn't specified" do
              before { ma_atom_map } # runs atom mapping
              it { expect(ma_s.atom(:cm)).to be_a(Concepts::Atom) }
            end
          end
        end

        describe 'many to one' do
          describe 'dimer formation' do
            it { expect(df_atom_map.changes).to match_array([
                [[activated_bridge, dimer_dup_ff],
                  [[activated_cd, dimer_dup_ff.atom(:cr)]]],
                [[activated_incoherent_bridge, dimer_dup_ff],
                  [[activated_incoherent_cd, dimer_dup_ff.atom(:cl)]]]
              ]) }

            describe 'correspond dimer atom is incoherent' do
              before(:each) { df_atom_map } # runs atom mapping
              it { expect(dimer_dup_ff.atom(:cl).incoherent?).to be_true }
              it { expect(dimer_dup_ff.atom(:cr)).to be_a(Concepts::Atom) }
            end
          end
        end
      end
    end

  end
end
