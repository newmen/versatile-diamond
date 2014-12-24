require 'spec_helper'

module VersatileDiamond
  module Mcs

    describe AtomMapper do
      describe '#self.map' do
        describe 'many to many' do
          describe 'bridge hydrogen migration' do
            let(:ab) { activated_bridge.dup }
            let(:mob) { methyl_on_bridge.dup }
            let(:b) { bridge.dup }
            let(:amob) { activated_methyl_on_bridge.dup }
            let(:args) do
              [
                [ab, mob],
                [b, amob],
                {
                  source: [[:b, ab], [:mob, mob]],
                  products: [[:b, b], [:mob, amob]]
                }
              ]
            end
            let(:changes) do
              [
                [[ab, b], [[ab.atom(:ct), b.atom(:ct)]]],
                [[mob, amob], [[mob.atom(:cm), amob.atom(:cm)]]]
              ]
            end
            it { expect(described_class.map(*args).changes).to match_array(changes) }
          end

          describe 'methyl activation' do
            let(:ma_s) { ma_source.first }
            let(:ma_p) { ma_products.first }
            let(:changes) { [[[ma_s, ma_p], [[ma_s.atom(:cm), ma_p.atom(:cm)]]]] }

            it { expect(ma_atom_map.changes).to match_array(changes) }

            describe "methyl on bridge isn't specified" do
              before { ma_atom_map } # runs atom mapping
              it { expect(ma_s.atom(:cm)).to be_a(Concepts::Atom) }
            end
          end
        end

        describe 'many to one' do
          describe 'dimer formation' do
            let(:ab) { df_source.first }
            let(:aib) { df_source.last }
            let(:d) { df_products.first }
            let(:changes) do
              [
                [[ab, d], [[ab.atom(:ct), d.atom(:cr)]]],
                [[aib, d], [[aib.atom(:ct), d.atom(:cl)]]]
              ]
            end

            it { expect(df_atom_map.changes).to match_array(changes) }

            describe 'correspond dimer atom is incoherent' do
              before(:each) { df_atom_map } # runs atom mapping
              it { expect(d.atom(:cl).incoherent?).to be_truthy }
              it { expect(d.atom(:cr)).to be_a(Concepts::Atom) }
            end
          end
        end
      end
    end

  end
end
