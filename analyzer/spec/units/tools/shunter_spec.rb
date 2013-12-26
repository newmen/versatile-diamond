require 'spec_helper'

using VersatileDiamond::Patches::RichString

module VersatileDiamond
  module Tools

    describe Shunter do
      let(:keyname_error) { Chest::KeyNameError }

      describe "#organize_dependecies!" do
        let(:lateral_dimer_formation) do
          dimer_formation.lateral_duplicate('lateral', [on_middle])
        end

        def store_and_organize_reactions
          Config.gas_concentration(hydrogen_ion, 1, 'mol/l')
          Config.gas_temperature(1000, 'K')
          Config.surface_temperature(500, 'K')

          surface_activation.rate = 0.1
          surface_activation.activation = 0
          surface_deactivation.rate = 0.2
          surface_deactivation.activation = 0

          methyl_activation.rate = 0.3
          methyl_activation.activation = 0
          methyl_deactivation.rate = 0.4
          methyl_deactivation.activation = 0

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

          methyl_incorporation.rate = 6
          methyl_incorporation.activation = 0

          # lateral dimer formation crated there
          lateral_dimer_formation.rate = 6
          lateral_dimer_formation.activation = 0

          [
            surface_activation, surface_deactivation,
            methyl_activation, methyl_deactivation, methyl_desorption,
            methyl_desorption.reverse, # synthetics
            hydrogen_migration, hydrogen_migration.reverse,
            dimer_formation, dimer_formation.reverse,
            lateral_dimer_formation, methyl_incorporation
          ].each { |reaction| Chest.store(reaction) }

          Shunter.organize_dependecies!
        end

        describe "#organize_specs_dependencies!" do
          before(:each) do
            [
              methane_base, bridge_base, dimer_base, high_bridge_base,
              methyl_on_bridge_base, methyl_on_dimer_base
            ].each { |spec| Chest.store(spec) }

            Shunter.organize_dependecies!
          end

          it { methane_base.parent.should be_nil }

          it { bridge_base.parent.should be_nil }
          it { bridge_base.childs.size.should == 3 }
          it { bridge_base.childs.should include(
              dimer_base, methyl_on_bridge_base, high_bridge_base
            ) }

          it { dimer_base.parent.should == bridge_base }
          it { dimer_base.childs.should == [methyl_on_dimer_base] }

          it { methyl_on_bridge_base.parent.should == bridge_base }
          it { methyl_on_bridge_base.childs.should be_empty }

          it { high_bridge_base.parent.should == bridge_base }
          it { high_bridge_base.childs.should be_empty }

          it { methyl_on_dimer_base.parent.should == dimer_base }
          it { methyl_on_dimer_base.childs.should be_empty }
        end

        describe "#organize_specific_spec_dependencies!" do
          before(:each) { store_and_organize_reactions }

          describe "#purge_null_rate_reactions!" do
            it { expect { Chest.reaction('forward methyl desorption') }.
              not_to raise_error }
            it { expect { Chest.reaction('reverse methyl desorption') }.
              to raise_error keyname_error }
          end

          describe "#collect_specific_specs!" do
            [
              Concepts::AtomicSpec,
              Concepts::ActiveBond,
              Concepts::SpecificSpec
            ].each do |type|
              RSpec::Matchers.define("be_#{type.to_s.underscore}") do
                match { |spec| spec.is_a?(type) }
              end
            end

            describe "surface activation" do
              it { Chest.atomic_spec(:H).should be_atomic_spec }
              it { Chest.specific_spec(:'hydrogen(h: *)').
                should be_specific_spec }
            end

            describe "surface deactivation" do
              it { Chest.active_bond(:*).should be_active_bond }
            end

            describe "methyl activation" do
              subject { Chest.specific_spec(:'methyl_on_bridge()') }
              it { should be_specific_spec }
              it { subject.parent.should be_nil }
              it { methyl_on_bridge_base.childs.should include(subject) }

              it { subject.childs.size.should == 2 }
              it { subject.childs.should include(
                  Chest.specific_spec(:'methyl_on_bridge(cm: *)'),
                  Chest.specific_spec(:'methyl_on_bridge(cm: i, cm: u)')
                ) }

              it { subject.reactions.should include(methyl_activation) }
            end

            describe "methyl deactivation" do
              subject { Chest.specific_spec(:'methyl_on_bridge(cm: *)') }
              it { should be_specific_spec }
              it { subject.parent.should == Chest.specific_spec(:'methyl_on_bridge()') }
              it { subject.childs.should be_empty }
              it { subject.reactions.should include(methyl_deactivation) }
            end

            describe "surface deactivation" do
              it { Chest.active_bond(:*).should be_active_bond }
            end

            describe "methyl desorption" do
              subject { Chest.specific_spec(:'methyl_on_bridge(cm: i, cm: u)') }
              it { should be_specific_spec }
              it { subject.parent.should == Chest.specific_spec(:'methyl_on_bridge()') }
              it { subject.childs.should be_empty }
              it { subject.reactions.should include(methyl_desorption) }
            end

            describe "forward hydrogen migration" do
              describe "dimer(cr: *)" do
                subject { Chest.specific_spec(:'dimer(cr: *)') }
                it { should be_specific_spec }
                it { subject.parent.should == Chest.specific_spec(:'dimer()') }
                it { subject.childs.should be_empty }
                it { subject.reactions.should include(hydrogen_migration) }
              end

              describe "methyl_on_dimer()" do
                subject { Chest.specific_spec(:'methyl_on_dimer()') }
                it { should be_specific_spec }
                it { subject.parent.should be_nil }
                it { methyl_on_dimer_base.childs.should include(subject) }

                it { subject.childs.should == [
                    Chest.specific_spec(:'methyl_on_dimer(cm: *)')
                  ] }
                it { subject.reactions.should include(hydrogen_migration) }
              end
            end

            describe "reverse hydrogen migration" do
              describe "dimer()" do
                subject { Chest.specific_spec(:'dimer()') }
                it { should be_specific_spec }
                it { subject.parent.should be_nil }
                it { dimer_base.childs.should include(subject) }

                it { subject.childs.size.should == 2 }
                it { subject.childs.should include(
                    Chest.specific_spec(:'dimer(cr: *)'),
                    Chest.specific_spec(:'dimer(cl: i)')
                  ) }

                it { subject.reactions.should include(hydrogen_migration.reverse) }

                it { subject.theres.size.should == 2 }
                it { subject.theres.first.where.name.should == :at_middle }
                it { subject.theres.last.where.name.should == :at_middle }
              end

              describe "methyl_on_dimer(cm: *)" do
                subject { Chest.specific_spec(:'methyl_on_dimer(cm: *)') }
                it { should be_specific_spec }
                it { subject.parent.should == Chest.specific_spec(:'methyl_on_dimer()') }
                it { subject.childs.should be_empty }
                it { subject.reactions.should include(hydrogen_migration.reverse) }
              end
            end

            describe "forward dimer formation" do
              describe "bridge(ct: *)" do
                subject { Chest.specific_spec(:'bridge(ct: *)') }
                it { should be_specific_spec }
                it { subject.parent.should be_nil }
                it { bridge_base.childs.should include(subject) }
                it { subject.childs.should == [
                    Chest.specific_spec(:'bridge(ct: *, ct: i)')
                  ] }
                it { subject.reactions.should include(dimer_formation) }
              end

              describe "bridge(ct: *, ct: i)" do
                subject { Chest.specific_spec(:'bridge(ct: *, ct: i)') }
                it { should be_specific_spec }
                it { subject.parent.should == Chest.specific_spec(:'bridge(ct: *)') }
                it { subject.childs.should be_empty }
                it { subject.reactions.should include(dimer_formation) }
              end
            end

            describe "reverse dimer formation" do
              subject { Chest.specific_spec(:'dimer(cl: i)') }
              it { should be_specific_spec }
              it { subject.parent.should == Chest.specific_spec(:'dimer()') }
              it { subject.childs.should be_empty }
              it { subject.reactions.should include(dimer_formation.reverse) }
            end

            describe "forward methyl incorporation" do
              describe "methyl_on_bridge(cm: *, cm: u)" do
                # other props checks in "methyl deactivation"
                it { Chest.specific_spec(:'methyl_on_bridge(cm: *)').reactions.
                  should include(methyl_incorporation) }
              end

              describe "dimer(cr: *)" do
                # other props checks in "forward hydrogen migration"
                it { Chest.specific_spec(:'dimer(cr: *)').reactions.
                  should include(methyl_incorporation) }
              end
            end
          end

          describe "swapping reaction specs" do
            let(:same) { Chest.specific_spec(:'hydrogen(h: *)') }

            it { surface_activation.source.should include(same) }
            it { surface_deactivation.source.should include(same) }
            it { methyl_activation.source.should include(same) }
            it { methyl_deactivation.source.should include(same) }

            it { lateral_dimer_formation.theres.map(&:env_specs).flatten.
              should include(Chest.specific_spec(:'dimer()')) }
            it { lateral_dimer_formation.theres.map(&:env_specs).flatten.
              select { |spec| spec == Chest.specific_spec(:'dimer()') }.size.
              should == 2 }
          end
        end

        describe "#check_reactions_for_duplicates" do
          let(:reaction_duplicate) { Shunter::ReactionDuplicate }

          shared_examples_for "duplicate or not" do
            before(:each) do
              Config.gas_temperature(1000, 'K')
              Config.surface_temperature(500, 'C')
            end

            describe "duplicate" do
              before do
                Chest.store(reaction)
                Chest.store(same)
              end

              it { expect { Shunter.organize_dependecies! }.
                to raise_error reaction_duplicate }
            end

            describe "not duplicate" do
              before do
                reaction.reverse.rate = reaction.rate
                reaction.reverse.activation = reaction.activation

                Chest.store(reaction)
                Chest.store(reaction.reverse) # synthetics
              end

              it { expect { Shunter.organize_dependecies! }.not_to raise_error }
            end
          end

          it_behaves_like "duplicate or not" do
            let(:reaction) { surface_deactivation }
            let(:same) do
              Concepts::UbiquitousReaction.new(
                :forward, 'duplicate', sd_source.shuffle, sd_product)
            end

            before(:each) do
              Config.gas_concentration(hydrogen_ion, 1, 'mol/l')
              reaction.rate = 1
              same.rate = 10
              reaction.activation = same.activation = 0
            end
          end

          it_behaves_like "duplicate or not" do
            let(:reaction) { dimer_formation }
            let(:same) { reaction.duplicate('same') }

            before(:each) do
              reaction.rate = 2
              reaction.activation = 0
              # need before setup reaction properties and same later, because
              # same is child of reaction and not it's not instanced
              same.rate = 20
              same.activation = 1
            end
          end

          it_behaves_like "duplicate or not" do
            let(:same) { dimer_formation.lateral_duplicate('same', [on_end]) }
            let(:reaction) do
              dimer_formation.lateral_duplicate('lateral', [on_end])
            end

            before(:each) do
              reaction; same # creates children of dimer formation
              dimer_formation.rate = 3
              dimer_formation.activation = 0
            end
          end
        end

        describe "#purge_unused_specs!" do
          before(:each) do
            [
              methane_base, bridge_base, methyl_on_bridge_base, dimer_base,
              methyl_on_dimer_base, ethylene_base, chloride_bridge_base,
              high_bridge_base
            ].each { |spec| Chest.store(spec) }
            store_and_organize_reactions
          end

          it { expect { Chest.spec(:methane) }.to raise_error keyname_error }
          it { expect { Chest.spec(:ethylene) }.to raise_error keyname_error }
          it { expect { Chest.spec(:chloride_bridge) }.to raise_error keyname_error }
          it { expect { Chest.spec(:high_bridge) }.to raise_error keyname_error }

          it { expect { Chest.spec(:bridge) }.not_to raise_error }
          it { expect { Chest.spec(:methyl_on_bridge) }.not_to raise_error }
          it { expect { Chest.spec(:dimer) }.not_to raise_error }

          describe "#purge_excess_extrime_specs!" do
            it { expect { Chest.spec(:methyl_on_dimer) }.to raise_error }
          end
        end
      end
    end

  end
end
