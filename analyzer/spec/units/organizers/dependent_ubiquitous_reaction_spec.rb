require 'spec_helper'

module VersatileDiamond
  module Organizers

    describe DependentUbiquitousReaction, type: :organizer do
      subject { dept_surface_activation }

      describe '#termination' do
        it { expect(subject.termination).to eq(adsorbed_h) }
        it { expect(dept_surface_deactivation.termination).to eq(active_bond) }
      end

      describe '#lateral?' do
        it { expect(subject.lateral?).to be_falsey }
      end

      describe '#organize_dependencies!' do
        shared_examples_for :cover_just_one do
          let(:all_reactions) { another_reactions + [complex] }
          let(:another_reactions) do
            [
              dept_methyl_desorption,
              dept_dimer_formation,
              dept_hydrogen_migration
            ]
          end

          let(:terms_cache) do
            term = target.termination
            { term.name => DependentTermination.new(term) }
          end

          let(:specs_cache) do
            all_reactions.each_with_object({}) do |reaction, cache|
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

          describe '#parents' do
            it { expect(complex.parents).to eq([target]) }
          end

          describe '#complexes' do
            it { expect(target.complexes).to eq([complex]) }
          end
        end

        it_behaves_like :cover_just_one do
          let(:target) { subject }
          let(:complex) { dept_methyl_activation }
          let(:term_name) { :H }
          let(:specific_name) { :'methyl_on_bridge()' }
        end

        it_behaves_like :cover_just_one do
          let(:target) { dept_surface_deactivation }
          let(:complex) { dept_methyl_deactivation }
          let(:term_name) { :* }
          let(:specific_name) { :'methyl_on_bridge(cm: *)' }
        end
      end
    end

  end
end
