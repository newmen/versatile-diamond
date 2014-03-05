require 'spec_helper'

module VersatileDiamond
  module Tools

    describe AtomClassifier, use: :atom_properties do
      subject { described_class.new }

      describe "#analyze" do
        before(:each) do
          [
            activated_bridge,
            dimer,
            activated_dimer,
            methyl_on_incoherent_bridge,
            high_bridge,
          ].each do |spec|
            subject.analyze(spec)
          end
        end

        describe "#props" do
          it { subject.props.size.should == 27 }
          it { subject.props.should include(ab_ct, bridge_cr, dimer_cr) }
        end

        describe "#organize_properties!" do
          def find(prop)
            subject.props[subject.index(prop)]
          end

          before(:each) { subject.organize_properties! }

          describe "#smallests" do
            it { find(high_cm).smallests.should be_nil }

            it { find(bridge_ct).smallests.should be_nil }
            it { find(ab_ct).smallests.to_a.should == [bridge_ct] }
            it { find(eab_ct).smallests.to_a.should == [ab_ct] }
            it { find(aib_ct).smallests.to_a.should == [ab_ct] }

            it { find(bridge_cr).smallests.to_a.should == [bridge_ct] }
            it { find(ab_cr).smallests.to_a.should == [ab_ct, bridge_cr] }
            it { find(ib_cr).smallests.to_a.should == [bridge_cr] }

            it { find(dimer_cr).smallests.to_a.should == [bridge_ct] }
            it { find(ad_cr).smallests.to_a.should == [ab_ct, dimer_cr] }
          end

          describe "#sames" do
            it { find(bridge_ct).sames.should be_nil }
            it { find(bridge_cr).sames.should be_nil }
            it { find(dimer_cr).sames.should be_nil }
            it { find(ab_ct).sames.should be_nil }

            it { find(aib_ct).sames.size.should == 1 }
            it { find(ad_cr).sames.size.should == 1 }

            it { find(eab_ct).sames.to_a.should == [aib_ct] }
            it { find(ab_cr).sames.to_a.should == [ib_cr] }
          end

          describe "#all_sames" do
            it { find(bridge_ct).all_sames.should be_nil }

            it { find(aib_ct).all_sames.size.should == 1 }
            it { find(eab_ct).all_sames.size.should == 2 }
            it { find(ad_cr).all_sames.size.should == 1 }

            it { find(ab_cr).all_sames.to_a.should == [ib_cr] }
          end

          describe "#general_transitive_matrix" do
            it { subject.general_transitive_matrix.to_a.should == [
                  [true, true, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
                  [false, true, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
                  [true, true, true, false, true, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
                  [false, false, false, true, true, false, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
                  [false, false, false, false, true, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
                  [false, false, false, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
                  [false, false, false, false, false, false, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
                  [false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
                  [false, false, false, false, false, false, false, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
                  [false, false, false, false, false, false, false, true, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
                  [false, false, false, false, true, false, false, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
                  [false, false, false, false, false, false, false, false, false, false, false, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
                  [false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
                  [false, false, false, false, false, false, false, false, false, false, false, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false],
                  [false, false, false, false, false, false, false, false, false, false, false, false, true, false, true, false, false, false, false, false, false, false, false, false, false, false, false],
                  [false, false, false, false, false, false, false, false, false, false, false, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false],
                  [false, false, false, false, false, false, false, false, false, false, false, false, true, false, true, false, true, false, false, false, false, false, false, false, false, false, false],
                  [false, false, false, false, false, false, false, false, false, false, false, true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false],
                  [false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, true, true, false, false, false, false, false, false, false],
                  [false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false],
                  [false, false, false, false, true, false, false, true, false, false, false, false, false, false, false, false, false, false, true, true, true, false, false, false, false, false, false],
                  [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, true, false, false, false, false],
                  [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false],
                  [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, true, true, true, false, false],
                  [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, true, false, false],
                  [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, true, true, true, true, false],
                  [false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true]
                ] }
          end

          describe "#specification" do
            it { subject.specification.should == [
                  0, 0, 2, 3, 3, 5, 6, 6, 8, 8, 10, 11, 11, 13, 13, 15, 15, 17, 18, 18, 20, 21, 21, 23, 23, 25, 26
                ] }
          end

          describe "#actives_to_deactives" do
            it { subject.actives_to_deactives.should == [
                  0, 1, 1, 6, 7, 4, 6, 7, 8, 9, 9, 11, 12, 11, 12, 13, 14, 16, 18, 19, 19, 21, 22, 21, 22, 24, 26
                ] }
          end

          describe "#deactives_to_actives" do
            it { subject.deactives_to_actives.should == [
                  2, 2, 2, 5, 5, 5, 3, 4, 10, 10, 10, 13, 14, 15, 16, 17, 17, 17, 20, 20, 20, 23, 24, 25, 25, 25, 26
                ] }
          end

          describe "generate graph" do
            let(:filename) { 'classifier_spec' }
            let(:graph) do
              Generators::ClassifierResultGraphGenerator.new(subject, filename)
            end
            it { expect { graph.generate }.to_not raise_error }

            # Comment line below for draw a graph which could help to inspect
            # dependencies between atom properties
            after { File.unlink("#{filename}.png") }
          end
        end

        describe "#classify" do
          describe "termination spec" do
            it { subject.classify(active_bond).should == {
                2 => ["^*C.%d<", 1],
                3 => ["*C:i%d<", 1],
                4 => ["*C%d<", 1],
                5 => ["**C%d<", 2],
                10 => ["-*C%d<", 1],
                13 => ["*C:i:u~", 1],
                14 => ["*C~", 1],
                15 => ["**C:i:u~", 2],
                16 => ["**C~", 2],
                17 => ["***C~", 3],
                20 => ["~*C%d<", 1],
                23 => ["*C:i=", 1],
                24 => ["*C=", 1],
                25 => ["**C=", 2],
              } }

            it { subject.classify(adsorbed_h).should == {
                0 => ["^C.:i%d<", 1],
                1 => ["^C.%d<", 1],
                3 => ["*C:i%d<", 1],
                4 => ["*C%d<", 1],
                6 => ["C:i%d<", 2],
                7 => ["C%d<", 2],
                8 => ["-C:i%d<", 1],
                9 => ["-C%d<", 1],
                11 => ["C:i:u~", 3],
                12 => ["C~", 3],
                13 => ["*C:i:u~", 2],
                14 => ["*C~", 2],
                15 => ["**C:i:u~", 1],
                16 => ["**C~", 1],
                18 => ["~C:i%d<", 1],
                19 => ["~C%d<", 1],
                21 => ["C:i=", 2],
                22 => ["C=", 2],
                23 => ["*C:i=", 1],
                24 => ["*C=", 1],
              } }

            it { subject.classify(adsorbed_cl).should be_empty }
          end

          describe "not termination spec" do
            it { subject.classify(activated_bridge).should == {
                1 => ['^C.%d<', 2],
                4 => ['*C%d<', 1],
              } }

            it { subject.classify(dimer).should == {
                1 => ['^C.%d<', 4],
                9 => ['-C%d<', 2],
              } }

            it { subject.classify(activated_dimer).should == {
                1 => ['^C.%d<', 4],
                9 => ['-C%d<', 1],
                10 => ['-*C%d<', 1],
              } }

            it { subject.classify(methyl_on_incoherent_bridge).should == {
                1 => ['^C.%d<', 2],
                12 => ['C~', 1],
                18 => ['~C:i%d<', 1],
              } }

            it { subject.classify(high_bridge).should == {
                1 => ["^C.%d<", 2],
                22 => ["C=", 1],
                26 => ["=C%d<", 1],
              } }

            describe "without" do
              it { subject.classify(activated_bridge, without: bridge_base).
                should == {
                  4 => ['*C%d<', 1]
                } }

              it { subject.classify(dimer, without: bridge_base).
                should == {
                  9 => ['-C%d<', 2]
                } }
            end
          end
        end

        describe "#index" do
          it { subject.index(bridge_cr).should == 1 }
          it { subject.index(bridge, bridge.atom(:cr)).should == 1 }

          it { subject.index(ab_ct).should == 4 }
          it { subject.index(activated_bridge, activated_bridge.atom(:ct)).
            should == 4 }
        end

        describe "#all_types_num" do
          it { subject.all_types_num.should == 27 }
        end

        describe "#notrelevant_types_num" do
          it { subject.notrelevant_types_num.should == 17 }
        end

        describe "#has_relevants?" do
          it { subject.has_relevants?(0).should be_true }
          it { subject.has_relevants?(6).should be_true }
          it { subject.has_relevants?(8).should be_true }
          it { subject.has_relevants?(15).should be_true }
          it { subject.has_relevants?(18).should be_true }
          it { subject.has_relevants?(21).should be_true }

          it { subject.has_relevants?(2).should be_false }
          it { subject.has_relevants?(4).should be_false }
          it { subject.has_relevants?(10).should be_false }
          it { subject.has_relevants?(12).should be_false }
          it { subject.has_relevants?(14).should be_false }
          it { subject.has_relevants?(20).should be_false }
          it { subject.has_relevants?(24).should be_false }
          it { subject.has_relevants?(26).should be_false }
        end
      end
    end

  end
end
