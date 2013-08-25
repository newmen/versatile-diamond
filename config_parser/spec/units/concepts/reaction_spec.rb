require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe Reaction, visitable: true do
      shared_examples_for "check duplicate property" do
        it { subject.name.should =~ /tail$/ }
        it { subject.source.should_not == df_source }
        it { subject.source.first.should_not == df_source.first }
        it { subject.products.should_not == df_products }
        it { subject.products.first.should_not == df_products.first }
        it { subject.products.last.should_not == df_products.last }

        shared_examples_for "both directions" do
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

        it_behaves_like "both directions" do
          let(:reaction) { dimer_formation }
          let(:child) { subject }
        end

        it_behaves_like "both directions" do
          let(:reaction) { dimer_formation.reverse }
          let(:child) { subject.reverse }
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
        it { subject.source.should include(methyl, md_products.last) }

        it { subject.products.should == [methyl_on_bridge] }
      end

      describe "#gases_num" do
        it { methyl_desorption.gases_num.should == 0 }
        it { methyl_desorption.reverse.gases_num.should == 1 }

        it { hydrogen_migration.gases_num.should == 0 }
        it { hydrogen_migration.reverse.gases_num.should == 0 }
      end

      describe "#swap_source" do
        # TODO: checks atom mapping result
      end

      describe "#positions" do
        [:one, :two].zip([:first, :last]).each do |l, m|
          let(l) { df_source.send(m).atom(:ct) }
        end

        let(:position) { [one, two, position_front] }
        before(:each) { dimer_formation.positions << position }

        it { dimer_formation.positions.should == [position] }
        it { dimer_formation.reverse.positions.should == [position] }
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
            hydrogen_migration.positions << [methyl_on_dimer.atom(:cb),
              activated_dimer.atom(:cr), position_front]
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
