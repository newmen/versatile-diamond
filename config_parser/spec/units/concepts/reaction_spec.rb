require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe Reaction do

      describe "#type" do
        it { methyl_desorption.type.should == :forward }
        it { hydrogen_migration.type.should == :forward }
        it { dimer_formation.type.should == :forward }
        it { methyl_incorporation.type.should == :forward }

        it { methyl_desorption.reverse.type.should == :reverse }
      end

      shared_examples_for "check duplicate property" do
        it { subject.name.should =~ /tail$/ }
        it { subject.reverse.name.should =~ /tail$/ }

        it { subject.source.should_not == df_source }
        it { subject.source.first.should_not == df_source.first }
        it { subject.products.should_not == df_products }
        it { subject.products.first.should_not == df_products.first }
        it { subject.products.last.should_not == df_products.last }

        shared_examples_for "child changes too" do
          %w(enthalpy activation rate).each do |prop|
            describe "children setup #{prop}" do
              before(:each) do
                child # makes a child
                reaction.send(:"#{prop}=", 456)
              end
              it { child.send(prop).should == 456 }
            end
          end
        end

        it_behaves_like "child changes too" do
          let(:reaction) { dimer_formation }
          let(:child) { subject }
        end

        it_behaves_like "child changes too" do
          let(:reaction) { dimer_formation.reverse }
          let(:child) { subject.reverse }
        end
      end

      describe "#as" do
        shared_examples_for "forward and reverse" do
          let(:name) { 'dimer formation' }
          before(:each) do
            subject.as(:forward).rate = 1
            subject.as(:forward).reverse.rate = 2
          end

          it { subject.as(:forward).rate.should == 1 } # tautology
          it { subject.as(:forward).name.should == "forward #{name}" }

          it { subject.as(:reverse).rate.should == 2 }
          it { subject.as(:reverse).name.should == "reverse #{name}" }
        end

        describe "dimer formation" do
          it_behaves_like "forward and reverse" do
            subject { dimer_formation }
          end

          it_behaves_like "forward and reverse" do
            subject { dimer_formation.reverse }
          end
        end

        describe "initialy inversed dimer formation" do
          it_behaves_like "forward and reverse" do
            subject do
              Reaction.new(:reverse, 'dimer formation',
                df_products, df_source, df_atom_map.reverse)
            end
          end
        end
      end

      describe "#duplicate" do
        subject { dimer_formation.duplicate('tail') }

        it_behaves_like "check duplicate property"
        it { subject.should be_a(described_class) }
      end

      describe "#lateral_duplicate" do
        subject { dimer_formation.lateral_duplicate('tail', [on_end]) }

        it_behaves_like "check duplicate property"
        it { subject.should be_a(LateralReaction) }
      end

      describe "#reverse" do
        subject { methyl_desorption.reverse }
        it { should be_a(described_class) }

        it { subject.source.size.should == 2 }
        it { subject.source.should include(methyl, abridge_dup) }

        it { subject.products.should == [methyl_on_bridge] }
      end

      describe "#gases_num" do
        it { methyl_desorption.gases_num.should == 0 }
        it { methyl_desorption.reverse.gases_num.should == 1 }

        it { hydrogen_migration.gases_num.should == 0 }
        it { hydrogen_migration.reverse.gases_num.should == 0 }
      end

      describe "#swap_source" do
        let(:bridge_dup) { activated_bridge.dup }
        before(:each) do
          dimer_formation.swap_source(activated_bridge, bridge_dup)
        end

        shared_examples_for "check specs existence" do
          it { should include(bridge_dup) }
          it { should_not include(activated_bridge) }
        end

        it_behaves_like "check specs existence" do
          subject { dimer_formation.positions.map(&:first).map(&:first) }
        end

        it_behaves_like "check specs existence" do
          subject { dimer_formation.positions.map { |p| p[1] }.map(&:first) }
        end

        it_behaves_like "check specs existence" do
          subject { df_atom_map.changes.map(&:first).map(&:first) }
        end
      end

      describe "#swap_atom" do
        let(:old_atom) { methyl_on_dimer.atom(:cr) }
        let(:new_atom) { old_atom.dup }

        before(:each) do
          # before need to set position between swapped atom and some other
          # atom
          hydrogen_migration.position_between(
            [methyl_on_dimer, old_atom],
            [activated_dimer, activated_dimer.atom(:cr)],
            position_100_front
          )
          # and then exchange target atom
          hydrogen_migration.swap_atom(methyl_on_dimer, old_atom, new_atom)
        end

        shared_examples_for "check atoms existence" do
          it { should include(new_atom) }
          it { should_not include(old_atom) }
        end

        it_behaves_like "check atoms existence" do
          subject { hydrogen_migration.positions.map(&:first).map(&:last) }
        end

        it_behaves_like "check atoms existence" do
          subject { hydrogen_migration.positions.map { |p| p[1] }.map(&:last) }
        end

        describe "atom mapping changes too" do
          it_behaves_like "check atoms existence" do
            let(:atoms) { hm_atom_map.full.map(&:last) }
            subject { atoms.first.map(&:first) + atoms.last.map(&:first) }
          end
        end
      end

      describe "#position_between" do
        before { hydrogen_migration.position_between(
            [methyl_on_dimer, methyl_on_dimer.atom(:cr)],
            [activated_dimer, activated_dimer.atom(:cr)],
            position_100_front
          ) }

        describe "opposite relation stored too" do
          it { hydrogen_migration.positions.should == [
              [
                [methyl_on_dimer, methyl_on_dimer.atom(:cr)],
                [activated_dimer, activated_dimer.atom(:cr)],
                position_100_front
              ],
              [
                [activated_dimer, activated_dimer.atom(:cr)],
                [methyl_on_dimer, methyl_on_dimer.atom(:cr)],
                position_100_front
              ],
            ] }
        end

        describe "apply to reverse" do
          subject { hydrogen_migration.reverse }

          it { subject.positions.should == [
              [
                [
                  activated_methyl_on_dimer,
                  activated_methyl_on_dimer.atom(:cr)
                ],
                [dimer, dimer.atom(:cr)],
                position_100_front
              ],
              [
                [dimer, dimer.atom(:cr)],
                [
                  activated_methyl_on_dimer,
                  activated_methyl_on_dimer.atom(:cr)
                ],
                position_100_front
              ],
            ] }
        end
      end

      describe "#positions" do
        describe "empty" do
          it { methyl_activation.positions.should be_empty }
          it { methyl_desorption.positions.should be_empty }
          it { hydrogen_migration.positions.should be_empty }
        end

        describe "dimer formation" do
          it { dimer_formation.positions.should == [
              [
                [activated_bridge, activated_bridge.atom(:ct)],
                [
                  activated_incoherent_bridge,
                  activated_incoherent_bridge.atom(:ct)
                ],
                position_100_front
              ],
              [
                [
                  activated_incoherent_bridge,
                  activated_incoherent_bridge.atom(:ct)
                ],
                [activated_bridge, activated_bridge.atom(:ct)],
                position_100_front
              ],
            ] }
        end
      end

      let(:reaction) { dimer_formation.duplicate('dup') }
      let(:lateral) { dimer_formation.lateral_duplicate('tail', [on_end]) }

      describe "#same?" do
        def make_same(type)
          source = [methyl_on_dimer.dup, activated_dimer.dup]
          products = [activated_methyl_on_dimer.dup, dimer.dup]
          names_to_specs = {
            source: [[:f, source.first], [:s, source.last]],
            products: [[:f, products.first], [:s, products.last]]
          }
          atom_map = Mcs::AtomMapper.map(source, products, names_to_specs)
          Reaction.new(type, 'duplicate', source, products, atom_map)
        end

        let(:same) { make_same(:forward) }
        it { hydrogen_migration.same?(same).should be_true }
        it { same.same?(hydrogen_migration).should be_true }

        it { methyl_activation.same?(methyl_deactivation).should be_false }
        it { methyl_desorption.same?(hydrogen_migration).should be_false }

        describe "different types" do
          let(:reverse) { make_same(:reverse) }
          it { hydrogen_migration.same?(same).should be_true }
          it { same.same?(hydrogen_migration).should be_true }
        end

        describe "positions are different" do
          before(:each) do
            hydrogen_migration.position_between(
              [methyl_on_dimer, methyl_on_dimer.atom(:cr)],
              [activated_dimer, activated_dimer.atom(:cr)],
              position_100_front
            )
          end

          it { hydrogen_migration.same?(same).should be_false }
          it { same.same?(hydrogen_migration).should be_false }
        end

        describe "lateral reaction" do
          it { reaction.same?(lateral).should be_true }
        end
      end

      describe "#complex_source_covered_by?" do
        it { methyl_activation.complex_source_covered_by?(adsorbed_h).
          should be_true }
        it { methyl_activation.complex_source_covered_by?(active_bond).
          should be_false }

        it { methyl_deactivation.complex_source_covered_by?(active_bond).
          should be_true }
        it { methyl_deactivation.complex_source_covered_by?(adsorbed_h).
          should be_true }
      end

      describe "#organize_dependencies! and #more_complex" do
        before(:each) do
          lateral_reactions = [lateral]
          reaction.organize_dependencies!(lateral_reactions)
          methyl_desorption.organize_dependencies!(lateral_reactions)
        end
        it { reaction.more_complex.should == [lateral] }
        it { methyl_desorption.more_complex.should be_empty }
      end

      describe "#size" do
        it { methyl_activation.size.should == 4 }
        it { dimer_formation.size.should == 8.34 }
      end

      it_behaves_like "visitable" do
        subject { methyl_desorption }
      end
    end

  end
end
