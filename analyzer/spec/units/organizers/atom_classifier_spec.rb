require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe AtomClassifier, type: :organizer, use: :atom_properties do
      subject { described_class.new([active_bond, adsorbed_h]) }

      shared_context :without_ubiquitous do
        subject { described_class.new }
      end

      describe '#analyze!' do
        before do
          [
            dept_activated_bridge,
            dept_extra_activated_bridge,
            dept_hydrogenated_bridge,
            dept_extra_hydrogenated_bridge,
            dept_right_hydrogenated_bridge,
            dept_dimer_base,
            dept_activated_dimer,
            dept_unfixed_methyl_on_bridge,
            dept_incoherent_methyl_on_bridge,
            dept_methyl_on_incoherent_bridge,
            dept_high_bridge,
          ].each do |spec|
            subject.analyze!(spec)
          end
        end

        describe '#props' do
          it { expect(subject.props.size).to eq(45) }
          it { expect(subject.props).to include(
              high_cm,
              bridge_ct, ab_ct, eab_ct, hb_ct, ahb_ct,
              bridge_cr, ab_cr,
              dimer_cr
            ) }
        end

        describe '#organize_properties!' do
          def find(prop)
            subject.props[subject.index(prop)]
          end

          before(:each) { subject.organize_properties! }

          describe '#smallests' do
            it { expect(find(high_cm).smallests).to be_empty }

            it { expect(find(bridge_ct).smallests).to be_empty }
            it { expect(find(ab_ct).smallests.to_a).to eq([bridge_ct]) }
            it { expect(find(hb_ct).smallests.to_a).to eq([bridge_ct]) }
            it { expect(find(eab_ct).smallests.to_a).to eq([ab_ct]) }
            it { expect(find(ehb_ct).smallests.to_a).to eq([hb_ct]) }
            it { expect(find(ahb_ct).smallests.to_a).to match_array([hb_ct, ab_ct]) }

            it { expect(find(bridge_cr).smallests.to_a).to eq([bridge_ct]) }
            it { expect(find(ab_cr).smallests.to_a).to match_array([ab_ct, bridge_cr]) }
            it { expect(find(hb_cr).smallests.to_a).to match_array([hb_ct, bridge_cr]) }

            it { expect(find(dimer_cr).smallests.to_a).to eq([bridge_ct]) }
            it { expect(find(ad_cr).smallests.to_a).to match_array([ab_ct, dimer_cr]) }
          end

          describe '#sames' do
            it { expect(find(bridge_ct).sames).to be_empty }
            it { expect(find(bridge_cr).sames).to be_empty }
            it { expect(find(dimer_cr).sames).to be_empty }
            it { expect(find(ab_ct).sames).to be_empty }

            it { expect(find(ahb_ct).sames).to be_empty }
            it { expect(find(ad_cr).sames).to be_empty }

            it { expect(find(eab_ct).sames).to be_empty }
            it { expect(find(ab_cr).sames).to be_empty }
          end

          describe '#general_transitive_matrix' do
            it { expect(subject.general_transitive_matrix.to_a).to eq([
                  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [1, 1, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0],
                  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0],
                  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0],
                  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 0, 0, 0, 0],
                  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0],
                  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0],
                  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0],
                  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0],
                  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]
                ]) }
          end

          describe 'all specifications' do
            def map_specifications(indexes)
              hs = subject.props_hash
              indexes.map.with_index { |ti, fi| [hs[fi].to_s, hs[ti].to_s] }
            end

            shared_examples_for :check_specification do
              let(:map_result) { map_specifications(spc_method.to_proc[subject]) }
              it { expect(map_result).to match_array(spc_pairs) }
            end

            describe '#specification' do
              let(:spc_method) { :specification }

              it_behaves_like :check_specification do
                let(:spc_pairs) do
                  [
                    ['***C~%d', '***C~%d'],
                    ['**C%d<', '**C%d<'],
                    ['**C:i~%d', 'H**C~%d'],
                    ['**C:u~%d', 'H**C~%d'],
                    ['**C=%d', '**C=%d'],
                    ['**C~%d', 'H**C~%d'],
                    ['*C%d<', 'H*C%d<'],
                    ['*C:i~%d', 'HH*C~%d'],
                    ['*C:u~%d', 'HH*C~%d'],
                    ['*C=%d', 'H*C=%d'],
                    ['*C~%d', 'HH*C~%d'],
                    ['-*C%d<', '-*C%d<'],
                    ['-C%d<', '-HC%d<'],
                    ['-HC%d<', '-HC%d<'],
                    ['>C%d<', '>C%d<'],
                    ['C%d<', 'HHC%d<'],
                    ['C:i~%d', 'HHHC~%d'],
                    ['C:u~%d', 'HHHC~%d'],
                    ['C=%d', 'HHC=%d'],
                    ['C~%d', 'HHHC~%d'],
                    ['H**C~%d', 'H**C~%d'],
                    ['H*C%d<', 'H*C%d<'],
                    ['H*C:i~%d', 'HH*C~%d'],
                    ['H*C:u~%d', 'HH*C~%d'],
                    ['H*C=%d', 'H*C=%d'],
                    ['H*C~%d', 'HH*C~%d'],
                    ['HC%d<', 'HHC%d<'],
                    ['HC:i~%d', 'HHHC~%d'],
                    ['HC:u~%d', 'HHHC~%d'],
                    ['HC=%d', 'HHC=%d'],
                    ['HC~%d', 'HHHC~%d'],
                    ['HH*C~%d', 'HH*C~%d'],
                    ['HHC%d<', 'HHC%d<'],
                    ['HHC:i~%d', 'HHHC~%d'],
                    ['HHC:u~%d', 'HHHC~%d'],
                    ['HHC=%d', 'HHC=%d'],
                    ['HHC~%d', 'HHHC~%d'],
                    ['HHHC~%d', 'HHHC~%d'],
                    ['^*C%d<', '^*C%d<'],
                    ['^C%d<', '^HC%d<'],
                    ['^HC%d<', '^HC%d<'],
                    ['_=C%d<', '_=C%d<'],
                    ['_~*C%d<', '_~*C%d<'],
                    ['_~C%d<', '_~HC%d<'],
                    ['_~C:i%d<', '_~HC%d<'],
                    ['_~HC%d<', '_~HC%d<'],
                  ]
                end
              end

              it_behaves_like :check_specification do
                include_context :without_ubiquitous
                let(:spc_pairs) do
                  [
                    ['**C%d<', '**C%d<'],
                    ['*C%d<', '*C:i%d<'],
                    ['*C:i%d<', '*C:i%d<'],
                    ['-*C%d<', '-*C%d<'],
                    ['-C%d<', '-C%d<'],
                    ['>C%d<', '>C%d<'],
                    ['C%d<', 'HHC%d<'],
                    ['C:i=%d', 'C:i=%d'],
                    ['C:i~%d', 'C:i~%d'],
                    ['C:u~%d', 'C:u~%d'],
                    ['C=%d', 'C:i=%d'],
                    ['C~%d', 'C:i~%d'],
                    ['HC%d<', 'HHC%d<'],
                    ['HHC%d<', 'HHC%d<'],
                    ['^C%d<', '^HC%d<'],
                    ['^HC%d<', '^HC%d<'],
                    ['_=C%d<', '_=C%d<'],
                    ['_~C%d<', '_~C:i%d<'],
                    ['_~C:i%d<', '_~C:i%d<'],
                  ]
                end
              end
            end

            describe '#actives_to_deactives' do
              let(:spc_method) { :actives_to_deactives }

              it_behaves_like :check_specification do
                let(:spc_pairs) do
                  [
                    ['***C~%d', 'H**C~%d'],
                    ['**C%d<', 'H*C%d<'],
                    ['**C:i~%d', 'HH*C~%d'],
                    ['**C:u~%d', 'HH*C~%d'],
                    ['**C=%d', 'H*C=%d'],
                    ['**C~%d', 'HH*C~%d'],
                    ['*C%d<', 'HHC%d<'],
                    ['*C:i~%d', 'HHHC~%d'],
                    ['*C:u~%d', 'HHHC~%d'],
                    ['*C=%d', 'HHC=%d'],
                    ['*C~%d', 'HHHC~%d'],
                    ['-*C%d<', '-HC%d<'],
                    ['-C%d<', '-HC%d<'],
                    ['-HC%d<', '-HC%d<'],
                    ['>C%d<', '>C%d<'],
                    ['C%d<', 'HHC%d<'],
                    ['C:i~%d', 'HHHC~%d'],
                    ['C:u~%d', 'HHHC~%d'],
                    ['C=%d', 'HHC=%d'],
                    ['C~%d', 'HHHC~%d'],
                    ['H**C~%d', 'HH*C~%d'],
                    ['H*C%d<', 'HHC%d<'],
                    ['H*C:i~%d', 'HHHC~%d'],
                    ['H*C:u~%d', 'HHHC~%d'],
                    ['H*C=%d', 'HHC=%d'],
                    ['H*C~%d', 'HHHC~%d'],
                    ['HC%d<', 'HHC%d<'],
                    ['HC:i~%d', 'HHHC~%d'],
                    ['HC:u~%d', 'HHHC~%d'],
                    ['HC=%d', 'HHC=%d'],
                    ['HC~%d', 'HHHC~%d'],
                    ['HH*C~%d', 'HHHC~%d'],
                    ['HHC%d<', 'HHC%d<'],
                    ['HHC:i~%d', 'HHHC~%d'],
                    ['HHC:u~%d', 'HHHC~%d'],
                    ['HHC=%d', 'HHC=%d'],
                    ['HHC~%d', 'HHHC~%d'],
                    ['HHHC~%d', 'HHHC~%d'],
                    ['^*C%d<', '^HC%d<'],
                    ['^C%d<', '^HC%d<'],
                    ['^HC%d<', '^HC%d<'],
                    ['_=C%d<', '_=C%d<'],
                    ['_~*C%d<', '_~HC%d<'],
                    ['_~C%d<', '_~HC%d<'],
                    ['_~C:i%d<', '_~HC%d<'],
                    ['_~HC%d<', '_~HC%d<'],
                  ]
                end
              end

              it_behaves_like :check_specification do
                include_context :without_ubiquitous
                # Incorrect case, because without ubiquitous reactions this method will
                # not be called
                let(:spc_pairs) do
                  [
                    ['**C%d<', '**C%d<'],
                    ['*C%d<', 'HHC%d<'],
                    ['*C:i%d<', '*C:i%d<'],
                    ['-*C%d<', '-*C%d<'],
                    ['-C%d<', '-C%d<'],
                    ['>C%d<', '>C%d<'],
                    ['C%d<', 'HHC%d<'],
                    ['C:i=%d', 'C:i=%d'],
                    ['C:i~%d', 'C:i~%d'],
                    ['C:u~%d', 'C:u~%d'],
                    ['C=%d', 'C:i=%d'],
                    ['C~%d', 'C:i~%d'],
                    ['HC%d<', 'HHC%d<'],
                    ['HHC%d<', 'HHC%d<'],
                    ['^C%d<', '^HC%d<'],
                    ['^HC%d<', '^HC%d<'],
                    ['_=C%d<', '_=C%d<'],
                    ['_~C%d<', '_~C:i%d<'],
                    ['_~C:i%d<', '_~C:i%d<'],
                  ]
                end
              end
            end

            describe '#deactives_to_actives' do
              let(:spc_method) { :deactives_to_actives }

              it_behaves_like :check_specification do
                let(:spc_pairs) do
                  [
                    ['***C~%d', '***C~%d'],
                    ['**C%d<', '**C%d<'],
                    ['**C:i~%d', '***C~%d'],
                    ['**C:u~%d', '***C~%d'],
                    ['**C=%d', '**C=%d'],
                    ['**C~%d', '***C~%d'],
                    ['*C%d<', '**C%d<'],
                    ['*C:i~%d', 'H**C~%d'],
                    ['*C:u~%d', 'H**C~%d'],
                    ['*C=%d', '**C=%d'],
                    ['*C~%d', 'H**C~%d'],
                    ['-*C%d<', '-*C%d<'],
                    ['-C%d<', '-*C%d<'],
                    ['-HC%d<', '-*C%d<'],
                    ['>C%d<', '>C%d<'],
                    ['C%d<', 'H*C%d<'],
                    ['C:i~%d', 'HH*C~%d'],
                    ['C:u~%d', 'HH*C~%d'],
                    ['C=%d', 'H*C=%d'],
                    ['C~%d', 'HH*C~%d'],
                    ['H**C~%d', '***C~%d'],
                    ['H*C%d<', '**C%d<'],
                    ['H*C:i~%d', 'H**C~%d'],
                    ['H*C:u~%d', 'H**C~%d'],
                    ['H*C=%d', '**C=%d'],
                    ['H*C~%d', 'H**C~%d'],
                    ['HC%d<', 'H*C%d<'],
                    ['HC:i~%d', 'HH*C~%d'],
                    ['HC:u~%d', 'HH*C~%d'],
                    ['HC=%d', 'H*C=%d'],
                    ['HC~%d', 'HH*C~%d'],
                    ['HH*C~%d', 'H**C~%d'],
                    ['HHC%d<', 'H*C%d<'],
                    ['HHC:i~%d', 'HH*C~%d'],
                    ['HHC:u~%d', 'HH*C~%d'],
                    ['HHC=%d', 'H*C=%d'],
                    ['HHC~%d', 'HH*C~%d'],
                    ['HHHC~%d', 'HH*C~%d'],
                    ['^*C%d<', '^*C%d<'],
                    ['^C%d<', '^*C%d<'],
                    ['^HC%d<', '^*C%d<'],
                    ['_=C%d<', '_=C%d<'],
                    ['_~*C%d<', '_~*C%d<'],
                    ['_~C%d<', '_~*C%d<'],
                    ['_~C:i%d<', '_~*C%d<'],
                    ['_~HC%d<', '_~*C%d<'],
                  ]
                end
              end

              it_behaves_like :check_specification do
                include_context :without_ubiquitous
                # Incorrect case, because without ubiquitous reactions this method will
                # not be called
                let(:spc_pairs) do
                  [
                    ['**C%d<', '**C%d<'],
                    ['*C%d<', '**C%d<'],
                    ['*C:i%d<', '**C%d<'],
                    ['-*C%d<', '-*C%d<'],
                    ['-C%d<', '-*C%d<'],
                    ['>C%d<', '>C%d<'],
                    ['C%d<', '*C:i%d<'],
                    ['C:i=%d', 'C:i=%d'],
                    ['C:i~%d', 'C:i~%d'],
                    ['C:u~%d', 'C:u~%d'],
                    ['C=%d', 'C:i=%d'],
                    ['C~%d', 'C:i~%d'],
                    ['HC%d<', '*C:i%d<'],
                    ['HHC%d<', 'HHC%d<'],
                    ['^C%d<', '^HC%d<'],
                    ['^HC%d<', '^HC%d<'],
                    ['_=C%d<', '_=C%d<'],
                    ['_~C%d<', '_~C:i%d<'],
                    ['_~C:i%d<', '_~C:i%d<'],
                  ]
                end
              end
            end
          end

          describe '#is?' do
            it { expect(subject.is?(hb_cr, bridge_ct)).to be_truthy }
            it { expect(subject.is?(bridge_ct, hb_cr)).to be_falsey }

            it { expect(subject.is?(eab_ct, ab_ct)).to be_truthy }
            it { expect(subject.is?(ab_ct, eab_ct)).to be_falsey }
            it { expect(subject.is?(eab_ct, bridge_ct)).to be_truthy }
            it { expect(subject.is?(bridge_ct, eab_ct)).to be_falsey }
          end

          describe '#children_of' do
            it { expect(subject.children_of(ab_ct)).to match_array([
                eab_ct, ahb_ct, ab_cr, ad_cr, ab_cb
              ]) }

            it { expect(subject.children_of(bridge_cr)).to match_array([
                ab_cr, hb_cr, tb_cc
              ]) }

            it { expect(subject.children_of(eab_ct)).to be_empty }
            it { expect(subject.children_of(ahb_ct)).to be_empty }
            it { expect(subject.children_of(ab_cr)).to be_empty }
            it { expect(subject.children_of(ad_cr)).to be_empty }
          end

          describe 'generate graph' do
            let(:filename) { 'classifier_spec' }
            let(:image_name) { "#{filename}.png" }
            let(:graph) do
              Generators::ClassifierResultGraph.new(subject, filename)
            end
            it { expect { graph.generate }.not_to raise_error }

            describe 'image is not empty' do
              before { graph.generate }
              it { expect(File.size(image_name) > 200).to be_truthy }
            end

            # Comment line below for draw a graph which could help to inspect
            # dependencies between atom properties
            after { File.unlink(image_name) }
          end
        end

        describe '#classify' do
          def props_list_for(spec)
            subject.classify(spec).map { |_, v| [v[0].to_s, v[1]] }
          end

          describe 'termination spec' do
            shared_examples_for :termination_classify do
              it { expect(props_list_for(term)).to match_array(props_list) }
            end

            it_behaves_like :termination_classify do
              let(:term) { dept_active_bond }
              let(:props_list) do
                [
                  ['***C~%d', 3],
                  ['**C%d<', 2],
                  ['**C:i~%d', 2],
                  ['**C:u~%d', 2],
                  ['**C=%d', 2],
                  ['**C~%d', 2],
                  ['*C%d<', 1],
                  ['*C:i~%d', 1],
                  ['*C:u~%d', 1],
                  ['*C=%d', 1],
                  ['*C~%d', 1],
                  ['-*C%d<', 1],
                  ['H**C~%d', 2],
                  ['H*C%d<', 1],
                  ['H*C:i~%d', 1],
                  ['H*C:u~%d', 1],
                  ['H*C=%d', 1],
                  ['H*C~%d', 1],
                  ['HH*C~%d', 1],
                  ['^*C%d<', 1],
                  ['_~*C%d<', 1],
                ]
              end
            end

            it_behaves_like :termination_classify do
              let(:term) { dept_adsorbed_h }
              let(:props_list) do
                [
                  ['**C:i~%d', 1],
                  ['**C:u~%d', 1],
                  ['**C~%d', 1],
                  ['*C%d<', 1],
                  ['*C:i~%d', 2],
                  ['*C:u~%d', 2],
                  ['*C=%d', 1],
                  ['*C~%d', 2],
                  ['-C%d<', 1],
                  ['-HC%d<', 1],
                  ['C%d<', 2],
                  ['C:i~%d', 3],
                  ['C:u~%d', 3],
                  ['C=%d', 2],
                  ['C~%d', 3],
                  ['H**C~%d', 1],
                  ['H*C%d<', 1],
                  ['H*C:i~%d', 2],
                  ['H*C:u~%d', 2],
                  ['H*C=%d', 1],
                  ['H*C~%d', 2],
                  ['HC%d<', 2],
                  ['HC:i~%d', 3],
                  ['HC:u~%d', 3],
                  ['HC=%d', 2],
                  ['HC~%d', 3],
                  ['HH*C~%d', 2],
                  ['HHC%d<', 2],
                  ['HHC:i~%d', 3],
                  ['HHC:u~%d', 3],
                  ['HHC=%d', 2],
                  ['HHC~%d', 3],
                  ['HHHC~%d', 3],
                  ['^C%d<', 1],
                  ['^HC%d<', 1],
                  ['_~C%d<', 1],
                  ['_~C:i%d<', 1],
                  ['_~HC%d<', 1],
                ]
              end
            end

            it_behaves_like :termination_classify do
              let(:term) { dept_adsorbed_cl }
              let(:props_list) { [] }
            end
          end

          describe 'not termination spec' do
            shared_examples_for :specific_classify do
              it { expect(props_list_for(spec)).to match_array(props_list) }
            end

            it_behaves_like :specific_classify do
              let(:spec) { dept_activated_bridge }
              let(:props_list) do
                [
                  ['*C%d<', 1],
                  ['^C%d<', 2]
                ]
              end
            end

            it_behaves_like :specific_classify do
              let(:spec) { dept_extra_activated_bridge }
              let(:props_list) do
                [
                  ['**C%d<', 1],
                  ['^C%d<', 2]
                ]
              end
            end

            it_behaves_like :specific_classify do
              let(:spec) { dept_hydrogenated_bridge }
              let(:props_list) do
                [
                  ['^C%d<', 2],
                  ['HC%d<', 1]
                ]
              end
            end

            it_behaves_like :specific_classify do
              let(:spec) { dept_extra_hydrogenated_bridge }
              let(:props_list) do
                [
                  ['^C%d<', 2],
                  ['HHC%d<', 1]
                ]
              end
            end

            it_behaves_like :specific_classify do
              let(:spec) { dept_right_hydrogenated_bridge }
              let(:props_list) do
                [
                  ['^C%d<', 1],
                  ['^HC%d<', 1],
                  ['C%d<', 1]
                ]
              end
            end

            it_behaves_like :specific_classify do
              let(:spec) { dept_dimer_base }
              let(:props_list) do
                [
                  ['-C%d<', 2],
                  ['^C%d<', 4]
                ]
              end
            end

            it_behaves_like :specific_classify do
              let(:spec) { dept_activated_dimer }
              let(:props_list) do
                [
                  ['-*C%d<', 1],
                  ['-C%d<', 1],
                  ['^C%d<', 4]
                ]
              end
            end

            it_behaves_like :specific_classify do
              let(:spec) { dept_methyl_on_incoherent_bridge }
              let(:props_list) do
                [
                  ['^C%d<', 2],
                  ['_~C:i%d<', 1],
                  ['C~%d', 1]
                ]
              end
            end

            it_behaves_like :specific_classify do
              let(:spec) { dept_high_bridge }
              let(:props_list) do
                [
                  ['^C%d<', 2],
                  ['_=C%d<', 1],
                  ['C=%d', 1]
                ]
              end
            end

            describe 'organize species dependencies' do
              shared_examples_for :organized_specific_classify do
                before { organize(all_species) }
                it { expect(props_list_for(target_spec)).to eq(props_list) }
              end

              it_behaves_like :organized_specific_classify do
                let(:target_spec) { dept_activated_bridge }
                let(:all_species) { [dept_activated_bridge] }
                let(:props_list) { [['*C%d<', 1]] }
              end

              it_behaves_like :organized_specific_classify do
                let(:target_spec) { dept_dimer_base }
                let(:all_species) { [dept_bridge_base, dept_dimer_base] }
                let(:props_list) { [['-C%d<', 2]] }
              end

              it_behaves_like :organized_specific_classify do
                let(:target_spec) { dept_activated_methyl_on_incoherent_bridge }
                let(:all_species) do
                  [
                    dept_activated_bridge,
                    dept_activated_dimer,
                    dept_activated_methyl_on_incoherent_bridge
                  ]
                end
                let(:props_list) do
                  [
                    ['*C~%d', 1],
                    ['_~C:i%d<', 1]
                  ]
                end
              end
            end
          end
        end

        describe '#index' do
          it { expect(subject.index(dept_bridge, bridge.atom(:cr))).to eq(34) }
          it { expect(subject.index(bridge_cr)).to eq(34) }

          let(:atom) { activated_bridge.atom(:ct) }
          it { expect(subject.index(dept_activated_bridge, atom)).to eq(29) }
          it { expect(subject.index(ab_ct)).to eq(29) }
        end

        describe '#has_relevants?' do
          it { expect(subject.has_relevants?(subject.index(ab_ct))).to be_falsey }
          it { expect(subject.has_relevants?(subject.index(ib_cb))).to be_truthy }

          describe 'there is relevant properties' do
            include_context :without_ubiquitous
            it { expect(subject.has_relevants?(subject.index(ihigh_cm))).to be_truthy }
          end
        end
      end
    end

  end
end
