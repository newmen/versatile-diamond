require 'spec_helper'

module VersatileDiamond
  module Organizers
    using Patches::RichString

    describe AnalysisResult do
      subject { described_class.new }
      let(:keyname_error) { Chest::KeyNameError }

      let(:lateral_dimer_formation) do
        dimer_formation.lateral_duplicate('lateral', [on_middle])
      end

      def store_bases
        [
          methane_base, bridge_base, dimer_base, high_bridge_base,
          methyl_on_bridge_base, methyl_on_dimer_base
        ].each { |spec| Tools::Chest.store(spec) }
      end

      def store_reactions
        Tools::Config.gas_concentration(hydrogen_ion, 1, 'mol/l')
        Tools::Config.gas_temperature(1000, 'K')
        Tools::Config.surface_temperature(500, 'K')

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
        ].each { |reaction| Tools::Chest.store(reaction) }
      end

      let(:instances) { subject.public_send(method) }
      let(:classes) { instances.map(&:class) }

      shared_examples_for :each_class_dependent do
        it { expect(instances.size).to eq(quant) }
        it { expect(classes.all? { |c| c == dependent_class }).to be_true }
      end

      describe 'reactions' do
        before { store_reactions }

        %w(ubiquitous typical lateral).zip([2, 8, 1]).each do |name, quant|
          describe "##{name}_reactions" do
            it_behaves_like :each_class_dependent do
              let(:dependent_class) { DependentReaction }
              let(:method) { :"#{name}_reactions" }
              let(:quant) { quant }
            end
          end
        end
      end

      describe 'specs' do
        let(:mono_method) { method.to_s[0..-2].to_sym }

        shared_examples_for :each_spec_dependent do
          it_behaves_like :each_class_dependent

          it { expect(instances.map(&:name)).to match_array(names) }
          it { expect(names.size).to eq(quant) }

          it 'all names are good keys' do
            names.each do |name|
              expect(subject.public_send(mono_method, name)).to_not be_nil
            end
          end
        end

        shared_examples_for :each_reactant_dependent do
          it_behaves_like :each_spec_dependent

          it 'all specs have reactions' do
            instances.each do |instance|
              expect(instance.reactions).to_not be_empty
            end
          end
        end

        describe '#term_specs' do
          before { store_reactions }

          it_behaves_like :each_reactant_dependent do
            let(:dependent_class) { DependentTermination }
            let(:method) { :term_specs }
            let(:quant) { 2 }
            let(:names) { [:*, :H] }
          end
        end

        describe '#base_specs' do
          shared_examples_for :all_dependent_base_specs do
            it_behaves_like :each_spec_dependent do
              let(:dependent_class) { DependentBaseSpec }
              let(:method) { :base_specs }
            end
          end

          describe 'from bases' do
            before { store_bases }

            it_behaves_like :all_dependent_base_specs do
              let(:quant) { 5 }
              let(:names) do
                [
                  :bridge,
                  :dimer,
                  :high_bridge,
                  :methyl_on_bridge,
                  :methyl_on_dimer
                ]
              end
            end
          end

          describe 'from reactions' do
            before { store_reactions }

            it_behaves_like :all_dependent_base_specs do
              let(:quant) { 6 }
              let(:names) do
                [
                  :bridge,
                  :dimer,
                  :extended_dimer,
                  :extended_methyl_on_bridge,
                  :methyl_on_bridge,
                  :methyl_on_dimer
                ]
              end
            end

            describe '#exchange_specs' do
              def get(name)
                subject.base_spec(name)
              end

              describe '.swap_source' do
                def base(name)
                  get(name).spec
                end

                let(:lateral_reaction) { subject.lateral_reactions.first.reaction }
                let(:used_there) { lateral_reaction.theres.map(&:env_specs).flatten }

                it { expect(used_there).
                  to match_array([base(:dimer), base(:dimer)]) }

                it { expect(hydrogen_migration.reverse.source).
                  to include(base(:dimer)) }
              end

              describe '#store_concept_to' do
                def reactions_for(name)
                  get(name).reactions
                end

                it { expect(reactions_for(:bridge)).to be_empty }

                it { expect(reactions_for(:dimer).map(&:reaction)).
                  to eq([hydrogen_migration.reverse]) }

                it { expect(reactions_for(:methyl_on_bridge)).to_not be_empty }
                it { expect(reactions_for(:methyl_on_dimer)).to_not be_empty }
              end
            end
          end
        end

        describe '#specific_specs' do
          def get(name)
            subject.specific_spec(name)
          end

          before { store_reactions }

          it_behaves_like :each_reactant_dependent do
            let(:dependent_class) { DependentSpecificSpec }
            let(:method) { :specific_specs }
            let(:quant) { 7 }
            let(:names) do
              [
                :'bridge(ct: *)',
                :'bridge(ct: *, ct: i)',
                # :'dimer()', # purged
                :'dimer(cl: i)',
                :'dimer(cr: *)',
                # :'extended_methyl_on_bridge(cm: *)', # purged
                # :'methyl_on_bridge()', # purged
                :'methyl_on_bridge(cm: *)',
                :'methyl_on_bridge(cm: i, cm: u)',
                # :'methyl_on_dimer()', # purged
                :'methyl_on_dimer(cm: *)'
              ]
            end
          end

          describe '#exchange_specs' do
            describe '.swap_source' do
              it { expect(methyl_incorporation.source).
                to include(get(:'methyl_on_bridge(cm: *)').spec) }
            end

            describe '#store_concept_to' do
              def reactions_for(name)
                get(name).reactions
              end

              it { expect(reactions_for(:'dimer(cl: i)').map(&:reaction)).
                to eq([dimer_formation.reverse]) }
            end
          end
        end

        describe '#organize_dependecies!' do
          before { store_reactions }

          describe '#organize_specific_spec_dependencies!' do
            let(:wrapped_specific) { subject.specific_spec(:'bridge(ct: *)') }
            let(:children) { [subject.specific_spec(:'bridge(ct: *, ct: i)')] }
            let(:parent) { subject.base_spec(:bridge) }

            it { expect(wrapped_specific.childs).to match_array(children) }
            it { expect(wrapped_specific.parent).to eq(parent) }
          end
        end






      #         it { expect(subject.reactions).to include(methyl_activation) }
      #       end
      #       end






      #   describe '#check_reactions_for_duplicates' do
      #     let(:reaction_duplicate) { Shunter::ReactionDuplicate }

      #     shared_examples_for 'duplicate or not' do
      #       before(:each) do
      #         Config.gas_temperature(1000, 'K')
      #         Config.surface_temperature(500, 'C')
      #       end

      #       describe 'duplicate' do
      #         before do
      #           Chest.store(reaction)
      #           Chest.store(same)
      #         end

      #         it { expect { Shunter.organize_dependecies! }.
      #           to raise_error reaction_duplicate }
      #       end

      #       describe 'not duplicate' do
      #         before do
      #           reaction.reverse.rate = reaction.rate
      #           reaction.reverse.activation = reaction.activation

      #           Chest.store(reaction)
      #           Chest.store(reaction.reverse) # synthetics
      #         end

      #         it { expect { Shunter.organize_dependecies! }.
      #           not_to raise_error }
      #       end
      #     end

      #     it_behaves_like 'duplicate or not' do
      #       let(:reaction) { surface_deactivation }
      #       let(:same) do
      #         Concepts::UbiquitousReaction.new(
      #           :forward, 'duplicate', sd_source.shuffle, sd_product)
      #       end

      #       before(:each) do
      #         Config.gas_concentration(hydrogen_ion, 1, 'mol/l')
      #         reaction.rate = 1
      #         same.rate = 10
      #         reaction.activation = same.activation = 0
      #       end
      #     end

      #     it_behaves_like 'duplicate or not' do
      #       let(:reaction) { dimer_formation }
      #       let(:same) { reaction.duplicate('same') }

      #       before(:each) do
      #         reaction.rate = 2
      #         reaction.activation = 0
      #         # need before setup reaction properties and same later, because
      #         # same is child of reaction and not it's not instanced
      #         same.rate = 20
      #         same.activation = 1
      #       end
      #     end

      #     it_behaves_like 'duplicate or not' do
      #       let(:same) { dimer_formation.lateral_duplicate('same', [on_end]) }
      #       let(:reaction) do
      #         dimer_formation.lateral_duplicate('lateral', [on_end])
      #       end

      #       before(:each) do
      #         reaction; same # creates children of dimer formation
      #         dimer_formation.rate = 3
      #         dimer_formation.activation = 0
      #       end
      #     end
      #   end

      end
    end

  end
end
