require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe AtomClassifier, type: :organizer, use: :atom_properties do
      subject { described_class.new([active_bond, adsorbed_h]) }

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
            dept_methyl_on_incoherent_bridge,
            dept_high_bridge,
          ].each do |spec|
            subject.analyze!(spec)
          end
        end

        describe '#props' do
          it { expect(subject.props.size).to eq(32) }
          it { expect(subject.props).to include(
              high_cm,
              bridge_ct, ab_ct, eab_ct, aib_ct, hb_ct, ehb_ct, hib_ct, ahb_ct,
              bridge_cr, ab_cr,
              ib_cr, dimer_cr, ad_cr
            ) }
        end

        describe '#organize_properties!' do
          def find(prop)
            subject.props[subject.index(prop)]
          end

          before(:each) { subject.organize_properties! }

          describe '#smallests' do
            it { expect(find(high_cm).smallests).to be_nil }

            it { expect(find(bridge_ct).smallests).to be_nil }
            it { expect(find(ab_ct).smallests.to_a).to eq([bridge_ct]) }
            it { expect(find(hb_ct).smallests.to_a).to eq([bridge_ct]) }
            it { expect(find(eab_ct).smallests.to_a).to eq([ab_ct]) }
            it { expect(find(aib_ct).smallests.to_a).to eq([ab_ct]) }
            it { expect(find(ehb_ct).smallests.to_a).to eq([hib_ct]) }
            it { expect(find(hib_ct).smallests.size).to eq(2) }
            it { expect(find(ahb_ct).smallests.to_a).
              to match_array([hb_ct, aib_ct]) }

            it { expect(find(bridge_cr).smallests.to_a).to eq([bridge_ct]) }
            it { expect(find(ib_cr).smallests.to_a).to eq([bridge_cr]) }
            it { expect(find(ab_cr).smallests.to_a).
              to match_array([ab_ct, bridge_cr]) }
            it { expect(find(hb_cr).smallests.to_a).
              to match_array([hb_ct, ib_cr]) }

            it { expect(find(dimer_cr).smallests.to_a).to eq([bridge_ct]) }
            it { expect(find(ad_cr).smallests.to_a).
              to match_array([ab_ct, dimer_cr]) }
          end

          describe '#sames' do
            it { expect(find(bridge_ct).sames).to be_nil }
            it { expect(find(bridge_cr).sames).to be_nil }
            it { expect(find(dimer_cr).sames).to be_nil }
            it { expect(find(ab_ct).sames).to be_nil }

            it { expect(find(aib_ct).sames.size).to eq(1) }
            it { expect(find(ahb_ct).sames.size).to eq(2) }
            it { expect(find(ad_cr).sames.size).to eq(1) }

            it { expect(find(eab_ct).sames.to_a).to eq([aib_ct]) }
            it { expect(find(ab_cr).sames.to_a).to eq([ib_cr]) }
          end

          describe '#general_transitive_matrix' do
            it { expect(subject.general_transitive_matrix.to_a).to eq([
                  [true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
                  [true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
                  [true, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
                  [true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
                  [true, false, true, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
                  [true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
                  [true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
                  [false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
                  [false, false, false, false, false, false, false, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
                  [false, false, false, false, false, false, false, true, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
                  [false, false, false, false, false, false, false, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
                  [false, false, false, false, false, false, false, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
                  [false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
                  [false, false, false, false, false, false, false, false, false, false, false, false, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
                  [false, false, false, false, false, false, false, false, false, false, false, false, true, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
                  [false, false, false, false, false, false, false, false, false, false, false, false, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
                  [false, false, false, false, false, false, false, false, false, false, false, false, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
                  [false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
                  [false, false, false, false, false, false, false, false, false, false, false, false, true, true, false, false, false, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
                  [false, false, false, false, false, false, false, false, false, false, false, false, true, true, true, true, false, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false],
                  [false, false, false, false, false, false, false, false, false, false, false, false, true, true, false, false, false, true, true, false, true, false, false, false, false, false, false, false, false, false, false, false, false],
                  [false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false],
                  [false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, true, true, false, false, false, false, false, false, false, false, false, false],
                  [false, false, false, false, false, false, false, false, false, false, false, false, true, false, true, false, false, false, false, false, false, true, true, true, false, false, false, false, false, false, false, false, false],
                  [false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, true, false, false, false, true, true, false, true, false, false, false, false, false, false, false, false],
                  [false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false],
                  [false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, true, true, false, false, false, false, false, false],
                  [false, false, false, false, false, false, false, false, false, false, false, false, true, false, true, false, false, false, false, false, false, false, false, false, false, true, true, true, false, false, false, false, false],
                  [false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false],
                  [false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, true, false, false, false],
                  [false, false, false, false, false, false, false, false, false, false, false, false, true, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, true, true, true, false, false],
                  [false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, true, false],
                  [false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true]
                ]) }
          end

          describe '#specification' do
            it { expect(subject.specification).to eq([
                1, 1, 3, 3, 5, 5, 6, 8, 8, 10,
                10, 11, 20, 20, 19, 19, 16, 20, 20, 19,
                20, 24, 24, 23, 24, 26, 26, 27, 29, 29,
                30, 31, 32
              ]) }
          end

          describe '#actives_to_deactives' do
            it { expect(subject.actives_to_deactives).to eq([
                0, 1, 0, 1, 2, 3, 4, 7, 8, 7,
                8, 9, 12, 13, 12, 13, 14, 17, 18, 17,
                20, 21, 22, 21, 24, 25, 26, 25, 28, 29,
                28, 31, 32
              ]) }
          end

          describe '#deactives_to_actives' do
            it { expect(subject.deactives_to_actives).to eq([
                2, 3, 4, 5, 6, 6, 6, 9, 10, 11,
                11, 11, 14, 15, 16, 16, 16, 19, 19, 19,
                20, 23, 23, 23, 24, 27, 27, 27, 30, 30,
                30, 31, 32
              ]) }
          end

          describe '#is?' do
            it { expect(subject.is?(hb_cr, ib_cr)).to be_truthy }
            it { expect(subject.is?(ib_cr, hb_cr)).to be_falsey }

            it { expect(subject.is?(hb_cr, bridge_ct)).to be_truthy }
            it { expect(subject.is?(bridge_ct, hb_cr)).to be_falsey }

            it { expect(subject.is?(eab_ct, ab_ct)).to be_truthy }
            it { expect(subject.is?(ab_ct, eab_ct)).to be_falsey }
            it { expect(subject.is?(eab_ct, aib_ct)).to be_truthy }
            it { expect(subject.is?(aib_ct, eab_ct)).to be_falsey }
            it { expect(subject.is?(eab_ct, bridge_ct)).to be_truthy }
            it { expect(subject.is?(bridge_ct, eab_ct)).to be_falsey }
          end

          describe '#children_of' do
            it { expect(subject.children_of(ab_ct)).to match_array([
                eab_ct, ahb_ct, ab_cr, ad_cr, ab_cb,
                raw_props(dept_activated_bridge, :ct, 'i')
              ]) }

            it { expect(subject.children_of(bridge_cr)).to match_array([
                ab_cr, hb_cr, tb_cc, ib_cr
              ]) }

            it { expect(subject.children_of(ib_cr)).to match_array([
                ab_cr, hb_cr, ib_cr
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
          def hash_str(spec)
            Hash[subject.classify(spec).map { |k, v| [k, [v[0].to_s, v[1]]] }]
          end

          describe 'termination spec' do
            shared_examples_for :termination_classify do
              it { expect(hash_str(term)).to eq(hash) }
            end

            it_behaves_like :termination_classify do
              let(:term) { dept_active_bond }
              let(:hash) do
                {
                  2 => ["*C~%d", 1],
                  3 => ["*C:i~%d", 1],
                  4 => ["**C~%d", 2],
                  5 => ["**C:i~%d", 2],
                  6 => ["***C~%d", 3],
                  9 => ["*C=%d", 1],
                  10 => ["*C:i=%d", 1],
                  11 => ["**C=%d", 2],
                  14 => ["*C%d<", 1],
                  15 => ["*C:i%d<", 1],
                  16 => ["**C%d<", 2],
                  19 => ["H*C%d<", 1],
                  23 => ["^*C%d<", 1],
                  27 => ["_~*C%d<", 1],
                  30 => ["-*C%d<", 1],
                }
              end
            end

            it_behaves_like :termination_classify do
              let(:term) { dept_adsorbed_h }
              let(:hash) do
                {
                  0 => ["C~%d", 3],
                  1 => ["C:i~%d", 3],
                  2 => ["*C~%d", 2],
                  3 => ["*C:i~%d", 2],
                  4 => ["**C~%d", 1],
                  5 => ["**C:i~%d", 1],
                  7 => ["C=%d", 2],
                  8 => ["C:i=%d", 2],
                  9 => ["*C=%d", 1],
                  10 => ["*C:i=%d", 1],
                  12 => ["C%d<", 2],
                  13 => ["C:i%d<", 2],
                  14 => ["*C%d<", 1],
                  15 => ["*C:i%d<", 1],
                  17 => ["HC%d<", 2],
                  18 => ["HC:i%d<", 2],
                  19 => ["H*C%d<", 1],
                  20 => ["HHC%d<", 2],
                  21 => ["^C%d<", 1],
                  22 => ["^C:i%d<", 1],
                  24 => ["^HC%d<", 1],
                  25 => ["_~C%d<", 1],
                  26 => ["_~C:i%d<", 1],
                  28 => ["-C%d<", 1],
                  29 => ["-C:i%d<", 1],
                }
              end
            end

            it_behaves_like :termination_classify do
              let(:term) { dept_adsorbed_cl }
              let(:hash) { {} }
            end
          end

          describe 'not termination spec' do
            shared_examples_for :specific_classify do
              it { expect(hash_str(spec)).to eq(hash) }
            end

            it_behaves_like :specific_classify do
              let(:spec) { dept_activated_bridge }
              let(:hash) do
                {
                  14 => ['*C%d<', 1],
                  21 => ['^C%d<', 2],
                }
              end
            end

            it_behaves_like :specific_classify do
              let(:spec) { dept_extra_activated_bridge }
              let(:hash) do
                {
                  16 => ['**C%d<', 1],
                  21 => ['^C%d<', 2],
                }
              end
            end

            it_behaves_like :specific_classify do
              let(:spec) { dept_hydrogenated_bridge }
              let(:hash) do
                {
                  17 => ['HC%d<', 1],
                  21 => ['^C%d<', 2],
                }
              end
            end

            it_behaves_like :specific_classify do
              let(:spec) { dept_extra_hydrogenated_bridge }
              let(:hash) do
                {
                  20 => ['HHC%d<', 1],
                  21 => ['^C%d<', 2],
                }
              end
            end

            it_behaves_like :specific_classify do
              let(:spec) { dept_right_hydrogenated_bridge }
              let(:hash) do
                {
                  12 => ['C%d<', 1],
                  21 => ['^C%d<', 1],
                  24 => ['^HC%d<', 1],
                }
              end
            end

            it_behaves_like :specific_classify do
              let(:spec) { dept_dimer_base }
              let(:hash) do
                {
                  21 => ['^C%d<', 4],
                  28 => ['-C%d<', 2],
                }
              end
            end

            it_behaves_like :specific_classify do
              let(:spec) { dept_activated_dimer }
              let(:hash) do
                {
                  21 => ['^C%d<', 4],
                  28 => ['-C%d<', 1],
                  30 => ['-*C%d<', 1],
                }
              end
            end

            it_behaves_like :specific_classify do
              let(:spec) { dept_methyl_on_incoherent_bridge }
              let(:hash) do
                {
                  0 => ['C~%d', 1],
                  21 => ['^C%d<', 2],
                  26 => ['_~C:i%d<', 1],
                }
              end
            end

            it_behaves_like :specific_classify do
              let(:spec) { dept_high_bridge }
              let(:hash) do
                {
                  7 => ['C=%d', 1],
                  21 => ['^C%d<', 2],
                  31 => ['_=C%d<', 1],
                }
              end
            end

            describe 'organize species dependencies' do
              shared_examples_for :organized_specific_classify do
                before { organize(all_species) }
                it { expect(hash_str(target_spec)).to eq(hash) }
              end

              it_behaves_like :organized_specific_classify do
                let(:target_spec) { dept_activated_bridge }
                let(:all_species) { [dept_activated_bridge] }
                let(:hash) do
                  { 14 => ['*C%d<', 1] }
                end
              end

              it_behaves_like :organized_specific_classify do
                let(:target_spec) { dept_dimer_base }
                let(:all_species) { [dept_bridge_base, dept_dimer_base] }
                let(:hash) do
                  { 28 => ['-C%d<', 2] }
                end
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
                let(:hash) do
                  {
                    2 => ['*C~%d', 1],
                    26 => ['_~C:i%d<', 1]
                  }
                end
              end
            end
          end
        end

        describe '#index' do
          it { expect(subject.index(dept_bridge, bridge.atom(:cr))).to eq(21) }
          it { expect(subject.index(bridge_cr)).to eq(21) }

          let(:atom) { activated_bridge.atom(:ct) }
          it { expect(subject.index(dept_activated_bridge, atom)).to eq(14) }
          it { expect(subject.index(ab_ct)).to eq(14) }
        end

        describe '#all_types_num' do
          it { expect(subject.all_types_num).to eq(32) }
        end

        describe '#has_relevants?' do
          it { expect(subject.has_relevants?(26)).to be_truthy }
          it { expect(subject.has_relevants?(2)).to be_falsey }
        end
      end
    end

  end
end
