require 'spec_helper'

module VersatileDiamond
  module Tools

    describe Chest do
      class Concept < Concepts::Named; end

      let(:concept) { Concept.new(:some) }
      let(:o_dups) { [Concept.new(:some)] }
      let(:o_another) { [Concept.new(:another)] }
      let(:m_dups) { [Concept.new(:first), Concept.new(:some)] }
      let(:m_another) { [Concept.new(:first), Concept.new(:second)] }

      let(:keyname_error) { Chest::KeyNameError }

      describe "#store" do
        it { (Chest.store(concept)).should == Chest }

        shared_examples_for "check duplication" do
          describe "duplication" do
            before { Chest.store(*dups) }
            it { expect { Chest.store(*dups.map(&:dup)) }.
              to raise_error keyname_error }
          end

          describe "another concept" do
            before { Chest.store(*dups) }
            it { expect { Chest.store(*another.map(&:dup)) }.
              to_not raise_error }
          end
        end

        it_behaves_like "check duplication" do
          let(:dups) { o_dups }
          let(:another) { o_another }
        end

        it_behaves_like "check duplication" do
          let(:dups) { m_dups }
          let(:another) { m_another }
        end
      end

      describe "#atom" do
        before { Chest.store(c) }
        it { Chest.atom(:C).should_not == c }
      end

      describe "#spec" do
        describe "gas spec" do
          before { Chest.store(methane_base) }
          it { Chest.spec(:methane).should == methane_base }
        end

        describe "surface spec" do
          before { Chest.store(bridge_base) }
          it { Chest.spec(:bridge).should == bridge_base }
        end
      end

      describe "#there" do
        let(:lateral) { dimers_row.make_lateral(one: 1, two: 2) }
        before(:each) do
          Chest.store(dimers_row, at_end)
          Chest.store(dimer_formation, lateral)
        end

        it { Chest.there(dimer_formation, :at_end).
          should be_a(Concepts::There) }
        it { expect { Chest.there(dimer_formation, :wrong) }.
          to raise_error keyname_error }

        describe "has many wheres" do
          let(:env) do
            e = Concepts::Environment.new(:some)
            e.targets = [:first, :second]; e
          end
          let(:another_lateral) { env.make_lateral(first: 'f', second: 's') }

          before do
            Chest.store(env, at_end)
            Chest.store(dimer_formation, another_lateral)
          end

          it { expect { Chest.there(dimer_formation, :at_end) }.
            to raise_error keyname_error }
        end
      end

      describe "#method_missing" do
        shared_examples_for "store and get concept" do
          before { Chest.store(*concepts) }
          it { Chest.concept(*concepts.map(&:name)).should == concepts.last }
        end

        it_behaves_like "store and get concept" do
          let(:concepts) { o_dups }
        end

        it_behaves_like "store and get concept" do
          let(:concepts) { m_dups }
        end

        it "wrong key of concept" do
          expect { Chest.wrong(:not_important) }.to raise_error keyname_error
        end

        it "wrong name of concept" do
          Chest.store(concept)
          expect { Chest.concept(:wrong) }.to raise_error keyname_error
        end
      end

      describe "#organize_dependecies" do
        describe "#reorganize_specs_dependencies" do
          before(:each) do
            [
              methane_base, bridge_base, dimer_base, high_bridge_base,
              methyl_on_bridge_base, methyl_on_dimer_base
            ].each { |spec| Chest.store(spec) }

            Chest.organize_dependecies
          end

          it { methane_base.dependent_from.should be_empty }
          it { bridge_base.dependent_from.should be_empty }
          it { dimer_base.dependent_from.to_a.should == [bridge_base] }
          it { methyl_on_bridge_base.dependent_from.to_a.
            should == [bridge_base] }
          it { high_bridge_base.dependent_from.to_a.
            should == [methyl_on_bridge_base] }
          it { methyl_on_dimer_base.dependent_from.to_a.
            should == [dimer_base] }
        end

        describe "#organize_specific_spec_dependencies" do
          before(:each) do
            Config.gas_temperature(1000, 'K')
            Config.surface_temperature(500, 'K')

            methyl_desorption.rate = 1
            methyl_desorption.activation = 0

            hydrogen_migration.rate = 2
            hydrogen_migration.activation = 0
            hydrogen_migration.reverse.rate = 3
            hydrogen_migration.reverse.activation = 1e3

            dimer_formation.rate = 4
            dimer_formation.activation = 0
            dimer_formation.reverse.rate = 5
            dimer_formation.reverse.activation = 2e3

            [
              methyl_desorption, hydrogen_migration, dimer_formation,
              hydrogen_migration.reverse,dimer_formation.reverse
            ].each { |reaction| Chest.store(reaction) }

            Chest.organize_dependecies
          end

          describe "#collect_specific_specs" do
            describe "methyl desorption" do
              it { Chest.specific_spec(:'methyl_on_bridge(cm: i, cm: u)').
                should be_a(Concepts::SpecificSpec) }
            end

            describe "forward hydrogen migration" do
              it { Chest.specific_spec(:'dimer(cr: *)').
                should be_a(Concepts::SpecificSpec) }
              it { Chest.specific_spec(:methyl_on_dimer).
                should be_a(Concepts::SpecificSpec) }
            end

            describe "reverse hydrogen migration" do
              it { Chest.specific_spec(:dimer).
                should be_a(Concepts::SpecificSpec) }
              it { Chest.specific_spec(:'methyl_on_dimer(cm: *)').
                should be_a(Concepts::SpecificSpec) }
            end

            describe "forward dimer formation" do
              it { Chest.specific_spec(:'bridge(ct: *)').
                should be_a(Concepts::SpecificSpec) }
              it { Chest.specific_spec(:'bridge(ct: *, ct: i)').
                should be_a(Concepts::SpecificSpec) }
            end

            describe "reverse dimer formation" do
              it { Chest.specific_spec(:'dimer(cl: i)').
                should be_a(Concepts::SpecificSpec) }
            end
          end

          describe "specific spec dependencies" do
            it { Chest.specific_spec(:'bridge(ct: *)').dependent_from.
              should be_nil }
            it { Chest.specific_spec(:'bridge(ct: *, ct: i)').dependent_from.
              should == Chest.specific_spec(:'bridge(ct: *)') }

            it { Chest.specific_spec(:dimer).dependent_from.should be_nil }
            it { Chest.specific_spec(:'dimer(cr: *)').dependent_from.
              should == Chest.specific_spec(:dimer) }
            it { Chest.specific_spec(:'dimer(cl: i)').dependent_from.
              should == Chest.specific_spec(:dimer) }

            it { Chest.specific_spec(:'methyl_on_bridge(cm: i, cm: u)').
              dependent_from.should be_nil }

            it { Chest.specific_spec(:methyl_on_dimer).dependent_from.
              should be_nil }
            it { Chest.specific_spec(:'methyl_on_dimer(cm: *)').
              dependent_from.should == Chest.specific_spec(:methyl_on_dimer) }
          end
        end

      end
    end

  end
end
