require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe FindAlgorithmBuilder, use: :engine_generator do
        let(:base_specs) { [] }
        let(:specific_specs) { [] }
        let(:generator) do
          stub_generator(base_specs: base_specs, specific_specs: specific_specs)
        end

        let(:code_specie) { generator.specie_class(subject.name) }
        let(:builder) { described_class.new(generator, code_specie) }

        describe '#pure_essence && #central_anchors' do
          [:ct, :cr, :cl, :cb, :cm, :cc].each do |keyname|
            let(keyname) { subject.atom(keyname) }
          end

          shared_examples_for :check_essence_and_anchors do
            it { expect(builder.pure_essence).to eq(essence) }
            it { expect(builder.central_anchors).to eq(central_anchors) }
          end

          it_behaves_like :check_essence_and_anchors do
            subject { bridge_base }
            let(:base_specs) { [dept_bridge_base] }

            let(:essence) { { ct => [[cl, bond_110_cross], [cr, bond_110_cross]] } }
            let(:central_anchors) { [[ct]] }
          end

          it_behaves_like :check_essence_and_anchors do
            subject { methyl_on_bridge_base }
            let(:base_specs) { [dept_bridge_base, dept_methyl_on_bridge_base] }

            let(:essence) { { cb => [[cm, free_bond]] } }
            let(:central_anchors) { [[cb]] }
          end

          it_behaves_like :check_essence_and_anchors do
            subject { activated_methyl_on_incoherent_bridge }
            let(:base_specs) { [dept_methyl_on_bridge_base] }
            let(:specific_specs) { [dept_activated_methyl_on_incoherent_bridge] }

            let(:essence) { { cb => [], cm => [] } }
            let(:central_anchors) { [[cb, cm]] }
          end

          it_behaves_like :check_essence_and_anchors do
            subject { high_bridge_base }
            let(:base_specs) { [dept_bridge_base, dept_high_bridge_base] }

            let(:essence) { { cb => [[cm, free_bond]] } }
            let(:central_anchors) { [[cb]] }
          end

          it_behaves_like :check_essence_and_anchors do
            subject { dimer_base }
            let(:base_specs) { [dept_bridge_base, dept_dimer_base] }

            let(:essence) { { cr => [[cl, bond_100_front]] } }
            let(:central_anchors) { [[cr]] }
          end

          it_behaves_like :check_essence_and_anchors do
            subject { methyl_on_dimer_base }
            let(:base_specs) do
              [
                dept_bridge_base,
                dept_methyl_on_bridge_base,
                dept_methyl_on_dimer_base
              ]
            end

            let(:essence) do
              {
                cr => [[cl, bond_100_front]],
                cl => [[cr, bond_100_front]]
              }
            end
            let(:central_anchors) { [[cr], [cl]] }
          end

          it_behaves_like :check_essence_and_anchors do
            subject { three_bridges_base }
            let(:base_specs) { [dept_bridge_base, dept_three_bridges_base] }

            let(:essence) { { ct => [], cc => [] } }
            let(:central_anchors) { [[ct]] }
          end

          it_behaves_like :check_essence_and_anchors do
            subject { activated_bridge }
            let(:base_specs) { [dept_bridge_base] }
            let(:specific_specs) { [dept_activated_bridge] }

            let(:essence) { { ct => [] } }
            let(:central_anchors) { [[ct]] }
          end
        end
      end

    end
  end
end
