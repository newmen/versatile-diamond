require 'spec_helper'

module VersatileDiamond
  module Tools

    describe AtomClassifier do
      let(:dc) { AtomClassifier::AtomProperties }

      let(:methyl) do
        dc.new(unfixed_methyl_on_bridge, unfixed_methyl_on_bridge.atom(:cm))
      end
      let(:c2b) { dc.new(high_bridge, high_bridge.atom(:cm)) }

      let(:bridge_ct) { dc.new(bridge, bridge.atom(:ct)) }
      let(:bridge_cr) { dc.new(bridge, bridge.atom(:cr)) }
      let(:dimer_cr) { dc.new(dimer, dimer.atom(:cr)) }
      let(:dimer_cl) { dc.new(dimer, dimer.atom(:cl)) }

      let(:ad_cr) { dc.new(activated_dimer, activated_dimer.atom(:cr)) }
      let(:ab_ct) { dc.new(activated_bridge, activated_bridge.atom(:ct)) }
      let(:aib_ct) do
        aib = activated_incoherent_bridge
        dc.new(aib, aib.atom(:ct))
      end
      let(:eab_ct) do
        dc.new(extra_activated_bridge, extra_activated_bridge.atom(:ct))
      end

      describe AtomProperties do
        describe "#atom_name" do
          it { bridge_ct.atom_name.should == :C }
        end

        describe "#valence" do
          it { methyl.valence.should == 4 }
          it { c2b.valence.should == 4 }
          it { bridge_ct.valence.should == 4 }
          it { bridge_cr.valence.should == 4 }
          it { ab_ct.valence.should == 4 }
          it { eab_ct.valence.should == 4 }
        end

        describe "#lattice" do
          it { methyl.lattice.should be_nil }
          it { bridge_ct.lattice.should == diamond }
        end

        describe "#relations" do
          it { methyl.relations.should == [free_bond] }
          it { c2b.relations.should == [:dbond] }
          it { bridge_ct.relations.should == [bond_110_cross, bond_110_cross] }
          it { bridge_cr.relations.should == [
              bond_110_cross, bond_110_cross, position_100_front, bond_110_front
            ] }

          it { ad_cr.relations.should == [
              :active, bond_100_front, bond_110_cross, bond_110_cross
            ] }

          it { aib_ct.relations.should == [
              :active, bond_110_cross, bond_110_cross
            ] }

          it { eab_ct.relations.should == [
              :active, :active, bond_110_cross, bond_110_cross
            ] }
        end

        describe "#relevants" do
          it { methyl.relevants.should == [:unfixed] }
          it { c2b.relevants.should be_nil }
          it { bridge_ct.relevants.should be_nil }
          it { ad_cr.relevants.should be_nil }
          it { aib_ct.relevants.should == [:incoherent] }
          it { eab_ct.relevants.should be_nil }
        end

        describe "#==" do
          it { methyl.should_not == c2b }
          it { c2b.should_not == methyl }

          it { bridge_ct.should_not == methyl }
          it { methyl.should_not == bridge_ct }

          it { bridge_ct.should_not == bridge_cr }
          it { bridge_cr.should_not == bridge_ct }

          it { bridge_ct.should_not == dimer_cr }
          it { dimer_cr.should_not == bridge_ct }

          it { dimer_cl.should == dimer_cr }
          it { dimer_cr.should == dimer_cl }

          it { bridge_ct.should_not == ab_ct }
          it { ab_ct.should_not == bridge_ct }

          it { ab_ct.should_not == aib_ct }
          it { aib_ct.should_not == ab_ct }

          it { ab_ct.should_not == eab_ct }
          it { eab_ct.should_not == ab_ct }

          it { aib_ct.should_not == eab_ct }
          it { eab_ct.should_not == aib_ct }
        end

        describe "#contained_in?" do
          it { methyl.contained_in?(c2b).should be_false }
          it { c2b.contained_in?(methyl).should be_false }

          it { methyl.contained_in?(bridge_cr).should be_false }
          it { bridge_cr.contained_in?(methyl).should be_false }

          it { bridge_ct.contained_in?(bridge_cr).should be_true }
          it { bridge_ct.contained_in?(dimer_cr).should be_true }
          it { bridge_ct.contained_in?(ab_ct).should be_true }
          it { bridge_ct.contained_in?(aib_ct).should be_true }

          it { dimer_cr.contained_in?(ad_cr).should be_true }
          it { ad_cr.contained_in?(dimer_cr).should be_false }

          it { ab_ct.contained_in?(ad_cr).should be_true }
          it { ad_cr.contained_in?(ab_ct).should be_false }

          it { ab_ct.contained_in?(eab_ct).should be_true }
          it { eab_ct.contained_in?(ab_ct).should be_false }

          it { dimer_cr.contained_in?(bridge_ct).should be_false }
          it { dimer_cr.contained_in?(bridge_cr).should be_false }
          it { ab_ct.contained_in?(bridge_cr).should be_false }
          it { bridge_cr.contained_in?(ab_ct).should be_false }
        end

        describe "#same_incoherent?" do
          it { ab_ct.same_incoherent?(ad_cr).should be_false }
          it { ad_cr.same_incoherent?(ab_ct).should be_false }
          it { ab_ct.same_incoherent?(eab_ct).should be_false }
          it { aib_ct.same_incoherent?(eab_ct).should be_false }
          it { eab_ct.same_incoherent?(ab_ct).should be_false }

          it { eab_ct.same_incoherent?(aib_ct).should be_true }
        end

        describe "#terminations_num" do
          it { methyl.terminations_num(active_bond).should == 0 }
          it { methyl.terminations_num(adsorbed_h).should == 3 }

          it { bridge_cr.terminations_num(active_bond).should == 0 }
          it { bridge_cr.terminations_num(adsorbed_h).should == 1 }

          it { ad_cr.terminations_num(active_bond).should == 1 }
          it { ad_cr.terminations_num(adsorbed_h).should == 0 }

          it { eab_ct.terminations_num(active_bond).should == 2 }
          it { eab_ct.terminations_num(adsorbed_h).should == 0 }
        end

        describe "#unrelevanted" do
          it { bridge_ct.unrelevanted.should == bridge_ct }
          it { bridge_ct.should == bridge_ct.unrelevanted }

          it { bridge_ct.should_not == ab_ct.unrelevanted }
          it { ab_ct.unrelevanted.should_not == bridge_ct }

          it { ab_ct.unrelevanted.should == aib_ct.unrelevanted }
          it { aib_ct.unrelevanted.should == ab_ct.unrelevanted }
        end

        describe "#incoherent?" do
          it { c2b.incoherent?.should be_false }
          it { ab_ct.incoherent?.should be_false }
          it { bridge_ct.incoherent?.should be_false }
          it { bridge_cr.incoherent?.should be_false }
          it { dimer_cr.incoherent?.should be_false }
          it { ad_cr.incoherent?.should be_false }
          it { ab_ct.incoherent?.should be_false }
          it { eab_ct.incoherent?.should be_false }

          it { aib_ct.incoherent?.should be_true }
        end

        describe "#incoherent" do
          it { ab_ct.incoherent.should == aib_ct }
          it { aib_ct.incoherent.should be_nil }

          it { bridge_cr.incoherent.should_not be_nil }
          it { bridge_cr.incoherent.should_not == aib_ct }

          it { ad_cr.incoherent.should be_nil }
        end

        describe "#active?" do
          it { bridge_ct.active?.should be_false }
          it { bridge_cr.active?.should be_false }
          it { dimer_cr.active?.should be_false }

          it { ad_cr.active?.should be_true }
          it { ab_ct.active?.should be_true }
          it { aib_ct.active?.should be_true }
        end

        describe "activated" do
          it { bridge_ct.activated.should == ab_ct }
          it { ad_cr.activated.should be_nil }

          it { bridge_cr.activated.activated.should be_nil }
        end

        describe "deactivated" do
          it { bridge_ct.deactivated.should be_nil }
          it { ab_ct.deactivated.should == bridge_ct }

          it { ab_ct.deactivated.deactivated.should be_nil }
        end

        describe "#smallests" do
          it { bridge_ct.smallests.should be_nil }
          it { ab_ct.smallests.should be_nil }

          describe "#add_smallest" do
            before(:each) { ab_ct.add_smallest(bridge_ct) }
            it { bridge_ct.smallests.should be_nil }
            it { ab_ct.smallests.to_a.should == [bridge_ct] }
          end
        end

        describe "#sames" do
          it { aib_ct.sames.should be_nil }
          it { eab_ct.sames.should be_nil }

          describe "#add_same" do
            before(:each) { eab_ct.add_same(aib_ct) }
            it { aib_ct.sames.should be_nil }
            it { eab_ct.sames.to_a.should == [aib_ct] }
          end
        end

        describe "#size" do
          it { bridge_ct.size.should == 6.5 }
          it { bridge_cr.size.should == 8.5 }
          it { dimer_cr.size.should == 7.5 }
          it { ab_ct.size.should == 7.5 }
          it { aib_ct.size.should == 7.84 }
        end
      end

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
            it { find(bridge_ct).smallests.should be_nil }

            it { find(bridge_cr).smallests.to_a.should == [find(bridge_ct)] }
            it { find(dimer_cr).smallests.to_a.should == [find(bridge_ct)] }
            it { find(ab_ct).smallests.to_a.should == [find(bridge_ct)] }
            it { find(aib_ct).smallests.to_a.should == [find(ab_ct)] }

            it { find(ad_cr).smallests.size.should == 2 }
            it { find(ad_cr).smallests.to_a.should include(dimer_cr, ab_ct) }
          end

          describe "#sames" do
            it { find(bridge_ct).sames.should be_nil }
            it { find(bridge_cr).sames.should be_nil }
            it { find(dimer_cr).sames.should be_nil }
            it { find(ab_ct).sames.should be_nil }

            it { find(aib_ct).sames.size.should == 1 }
            it { find(ad_cr).sames.size.should == 1 }
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
                13 => ["*C:i~", 1],
                14 => ["*C~", 1],
                15 => ["**C:i~", 2],
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
                11 => ["C:i~", 3],
                12 => ["C~", 3],
                13 => ["*C:i~", 2],
                14 => ["*C~", 2],
                15 => ["**C:i~", 1],
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

        # describe "#has_relevants?" do
        # end

        describe "#general_transitive_matrix" do
          it { subject.general_transitive_matrix.to_a.size.
            should == subject.all_types_num }
        end

        describe "#specification" do
          it { subject.specification.size.should == subject.all_types_num }
        end

        describe "#actives_to_deactives" do
          it { subject.actives_to_deactives.size.
            should == subject.all_types_num }
        end

        describe "#deactives_to_actives" do
          it { subject.deactives_to_actives.size.
            should == subject.all_types_num }
        end
      end
    end

  end
end
