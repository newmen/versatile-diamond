require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe DependentUbiquitousReaction do
      def wrap(reaction)
        described_class.new(reaction)
      end

      subject { wrap(surface_activation) }

      describe '#termination' do
        it { expect(subject.termination).to eq(adsorbed_h) }
      end

      describe '#organize_dependencies!' do
        def typical(reaction)
          DependentTypicalReaction.new(reaction)
        end

        shared_examples_for :cover_just_one do
          let(:all_reactions) { another_reactions + [complex] }
          let(:another_reactions) do
            [
              methyl_desorption,
              dimer_formation,
              hydrogen_migration
            ].map { |r| typical(r) }
          end

          let(:terms_cache) do
            term = target.termination
            { term.name => DependentTermination.new(term) }
          end

          let(:specs_cache) do
            all_reactions.each.with_object({}) do |reaction, cache|
              reaction.each_source do |spec|
                cache[spec.name] = DependentSpecificSpec.new(spec)
              end
            end
          end

          before do
            target.organize_dependencies!(all_reactions, terms_cache, specs_cache)
          end

          describe 'terminations are have parents' do
            it { expect(terms_cache[term_name].parents).
              to eq([specs_cache[specific_name]]) }
          end

          describe 'specific species are have children' do
            it { expect(specs_cache[specific_name].children).
              to eq([terms_cache[term_name]]) }
          end

          describe '#parent' do
            it { expect(complex.parent).to eq(target) }
          end

          describe '#complexes' do
            it { expect(target.complexes).to eq([complex]) }
          end
        end

        it_behaves_like :cover_just_one do
          let(:target) { subject }
          let(:complex) { typical(methyl_activation) }
          let(:term_name) { :H }
          let(:specific_name) { :'methyl_on_bridge()' }
        end

        it_behaves_like :cover_just_one do
          let(:target) { wrap(surface_deactivation) }
          let(:complex) { typical(methyl_deactivation) }
          let(:term_name) { :* }
          let(:specific_name) { :'methyl_on_bridge(cm: *)' }
        end
      end
    end

  end
end
