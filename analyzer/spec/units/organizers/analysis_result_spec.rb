require 'spec_helper'

module VersatileDiamond
  module Organizers
    using Patches::RichString

    describe AnalysisResult do
      subject { described_class.new }
      let(:keyname_error) { Chest::KeyNameError }

      def store_base_specs(specific_specs)
        specific_specs.each do |specific_spec|
          base_spec = specific_spec.spec
          Tools::Chest.store(base_spec) unless Tools::Chest.has?(base_spec)
        end
      end

      def store_reactions
        Tools::Config.gas_concentration(hydrogen_ion, 1, 'mol/l')
        Tools::Config.gas_temperature(1000, 'K')
        Tools::Config.surface_temperature(500, 'K')

        # ubuqitous[0]
        surface_activation.rate = 0.1
        # ubuqitous[1]
        surface_deactivation.rate = 0.2

        # typical[0]
        methyl_activation.rate = 0.3
        # typical[1]
        methyl_deactivation.rate = 0.4

        # typical[2]
        methyl_desorption.rate = 1

        # typical[3]
        hydrogen_migration.rate = 2
        # typical[4]
        hydrogen_migration.reverse.rate = 3
        hydrogen_migration.reverse.activation = 1e3

        # typical[5]
        dimer_formation.rate = 4
        # typical[6]
        dimer_formation.reverse.rate = 5
        dimer_formation.reverse.activation = 2e3

        # typical[7]
        methyl_incorporation.rate = 6

        # lateral[0]
        end_lateral_df.rate = 6

        # lateral[1]
        middle_lateral_df.rate = 7

        ubiquitous = [surface_activation, surface_deactivation]

        typicals = [methyl_activation, methyl_deactivation,
          methyl_desorption, methyl_desorption.reverse, # synthetics
          hydrogen_migration, hydrogen_migration.reverse,
          dimer_formation, dimer_formation.reverse, methyl_incorporation]

        laterals = [end_lateral_df, middle_lateral_df]

        (typicals + laterals).each do |reaction|
          store_base_specs(reaction.source)
        end

        laterals.each do |reaction|
          reaction.theres.each do |there|
            store_base_specs(there.where.specs)
          end
        end

        (ubiquitous + typicals + laterals).each do |reaction|
          Tools::Chest.store(reaction)
        end
      end

      let(:instances) { subject.public_send(method) }

      shared_examples_for :each_class_dependent do
        it { expect(instances.size).to eq(quant) }
        it { expect(instances.all? { |c| c.is_a?(dependent_class) }).to be_truthy }
      end

      describe 'reactions' do
        before { store_reactions }

        %w(ubiquitous typical lateral).
          zip([
            DependentUbiquitousReaction,
            DependentTypicalReaction,
            DependentLateralReaction
          ]).
          zip([2, 8, 2]).each do |(name, klass), quant|
            describe "##{name}_reactions" do
              it_behaves_like :each_class_dependent do
                let(:dependent_class) { klass }
                let(:method) { :"#{name}_reactions" }
                let(:quant) { quant }
              end
            end
        end
      end

      describe 'lateral entities' do
        before { store_reactions }

        describe '#theres' do
          it { expect(subject.theres.map(&:class)).to eq([DependentThere] * 2) }
          it { expect(subject.theres.map(&:lateral_reaction).map(&:reaction)).
            to match_array([end_lateral_df, middle_lateral_df]) }
        end
      end

      describe 'specs' do
        let(:mono_method) { method.to_s[0..-2].to_sym }

        shared_examples_for :each_spec_dependent do
          let(:quant) { names.size }
          it_behaves_like :each_class_dependent

          it { expect(instances.map(&:name)).to match_array(names) }

          it 'all names are good keys' do
            names.each do |name|
              expect(subject.public_send(mono_method, name)).not_to be_nil
            end
          end
        end

        shared_examples_for :each_reactant_dependent do
          it_behaves_like :each_spec_dependent

          it 'all specs have reactions' do
            instances.each do |instance|
              expect(instance.reactions).not_to be_empty
            end
          end
        end

        describe '#term_specs' do
          before { store_reactions }

          it_behaves_like :each_reactant_dependent do
            let(:dependent_class) { DependentTermination }
            let(:method) { :term_specs }
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
            before do
              [
                methane_base, bridge_base_dup, bridge_base, dimer_base,
                high_bridge_base, methyl_on_bridge_base, methyl_on_dimer_base
              ].each { |spec| Tools::Chest.store(spec) }
            end

            it_behaves_like :all_dependent_base_specs do
              let(:names) do
                [
                  # :bridge, # purged
                  # :bridge_dup, # purged
                  # :dimer, # purged
                  # :high_bridge, # purged
                  # :methyl_on_dimer, # purged
                  # :methyl_on_bridge # purged
                ]
              end
            end
          end

          describe 'from reactions' do
            before { store_reactions }

            it_behaves_like :all_dependent_base_specs do
              let(:names) do
                [
                  :bridge,
                  :dimer,
                  # :extended_dimer, # purged
                  # :extended_methyl_on_bridge, # purged
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

                let(:lateral_reaction) { subject.lateral_reactions.last.reaction }
                let(:used_there) { lateral_reaction.theres.flat_map(&:env_specs) }

                it { expect(used_there.uniq.size > 1).to be_truthy }
                it { expect(used_there.map(&:name)).to match_array([:dimer, :dimer]) }
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

                it { expect(reactions_for(:methyl_on_bridge)).not_to be_empty }
                it { expect(reactions_for(:methyl_on_dimer)).not_to be_empty }
              end
            end
          end
        end

        describe '#specific_specs' do
          def get(name)
            subject.specific_spec(name)
          end

          describe 'collection from reactions' do
            before { store_reactions }

            it_behaves_like :each_reactant_dependent do
              let(:dependent_class) { DependentSimpleSpec }
              let(:method) { :specific_specs }
              let(:names) do
                [
                  :'hydrogen(h: *)',
                  :'bridge(ct: *)',
                  :'bridge(ct: *, ct: i)',
                  # :'dimer()', # purged
                  :'dimer(cl: i)',
                  :'dimer(cr: *)',
                  # :'extended_methyl_on_bridge(cm: *)', # purged
                  # :'methyl_on_bridge()', # purged
                  :'methyl_on_bridge(cm: *)',
                  :'methyl_on_bridge(cm: i)',
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

          describe 'collection from config' do
            before do
              Tools::Config.gas_concentration(methyl, 1, 'mol/l')
              Tools::Config.gas_concentration(hydrogen_ion, 2, 'mol/l')
            end

            it { expect(get(:'hydrogen(h: *)')).not_to be_nil }
            it { expect(get(:'methane(c: *)')).not_to be_nil }
          end
        end

        describe '#organize_dependecies!' do
          describe '#organize_specific_specs_dependencies!' do
            before { store_reactions }

            let(:wrapped_specific) { subject.specific_spec(:'bridge(ct: *)') }
            let(:children) { [subject.specific_spec(:'bridge(ct: *, ct: i)')] }
            let(:parent) { subject.base_spec(:bridge) }

            it { expect(wrapped_specific.children).to match_array(children) }
            it { expect(wrapped_specific.parents.map(&:original)).to eq([parent]) }
          end

          describe '#check_reactions_for_duplicates' do
            let(:reaction_duplicate) { described_class::ReactionDuplicate }

            shared_examples_for :duplicate_or_not do
              def store_to_chest(reaction)
                reaction.rate = 1
                reaction.activation = 0
                Tools::Chest.store(reaction)
              end

              before do
                Tools::Config.gas_temperature(1000, 'K')
                Tools::Config.surface_temperature(500, 'C')
              end

              describe 'duplicate' do
                before do
                  store_to_chest(reaction)
                  store_to_chest(same)
                end

                it { expect { subject }.to raise_error reaction_duplicate }
              end

              describe 'not duplicate' do
                before do
                  store_to_chest(reaction)
                  store_to_chest(reaction.reverse) # synthetics
                end

                it { expect { subject }.not_to raise_error }
              end
            end

            it_behaves_like :duplicate_or_not do
              let(:reaction) { surface_deactivation }
              let(:same) do
                Concepts::UbiquitousReaction.new(
                  :forward, 'duplicate', sd_source.shuffle, sd_product)
              end

              before { Tools::Config.gas_concentration(hydrogen_ion, 1, 'mol/l') }
            end

            it_behaves_like :duplicate_or_not do
              let(:reaction) { dimer_formation }
              let(:same) { reaction.duplicate('same') }

              before { store_base_specs(df_source + df_products) }
            end

            it_behaves_like :duplicate_or_not do
              let(:reaction) { end_lateral_df }
              let(:same) { dimer_formation.lateral_duplicate('same', [on_end]) }

              before { store_base_specs(df_source + df_products + at_middle.specs) }
            end
          end

          describe '#organize_reactions_dependencies!' do
            before { store_reactions }

            shared_examples_for :expect_complex do
              it { expect(reaction.complexes).to eq([complex]) }
            end

            describe 'ubiquitous' do
              it_behaves_like :expect_complex do
                let(:reaction) { subject.ubiquitous_reactions.first }
                let(:complex) { subject.typical_reactions.first }
              end
            end

            describe 'typical' do
              it_behaves_like :expect_complex do
                # index of reactions see in comments of #store_reactions method
                let(:reaction) { subject.typical_reactions[5] }
                let(:complex) { subject.lateral_reactions.first }
              end
            end

            describe 'lateral' do
              it_behaves_like :expect_complex do
                # index of reactions see in comments of #store_reactions method
                let(:reaction) { subject.lateral_reactions.first }
                let(:complex) { subject.lateral_reactions.last }
              end
            end

            describe 'organization termination species dependencies' do
              shared_examples_for :termination_parents do
                let(:parents) { subject.term_spec(term_name).parents }
                let(:specific) { subject.public_send(spec_method, spec_name) }

                it { expect(parents).to eq([specific]) }
              end

              it_behaves_like :termination_parents do
                let(:term_name) { :H }
                let(:spec_name) { :methyl_on_bridge }
                let(:spec_method) { :base_spec }
              end

              it_behaves_like :termination_parents do
                let(:term_name) { :* }
                let(:spec_name) { :'methyl_on_bridge(cm: *)' }
                let(:spec_method) { :specific_spec }
              end
            end
          end

          describe '#organize_base_specs_dependencies!' do
            before { store_reactions }

            let(:wrapped_base) { subject.base_spec(:dimer) }
            let(:parent) { subject.base_spec(:bridge) }
            let(:children) do
              [
                subject.specific_spec(:'dimer(cr: *)'),
                subject.specific_spec(:'dimer(cl: i)')
              ]
            end

            it { expect(wrapped_base.children).to match_array(children) }
            it { expect(wrapped_base.parents.map(&:original)).to eq([parent, parent]) }
          end
        end
      end
    end

  end
end
