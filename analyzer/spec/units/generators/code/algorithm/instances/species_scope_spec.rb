require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Instances

        describe SpeciesScope, type: :algorithm do
          def make_scope(original, proxy_specs)
            uniqs = proxy_specs.map { |spec| UniqueParent.new(generator, spec) }
            described_class.new(generator, original, uniqs)
          end

          let(:generator) { stub_generator(base_specs: base_specs) }
          let(:base_specs) do
            [
              dept_bridge_base,
              dept_methyl_on_bridge_base,
              dept_cross_bridge_on_bridges_base
            ]
          end

          subject { make_scope(original_specie, parent_specs) }
          let(:parent_specs) { original_specie.spec.parents }
          let(:original_specie) do
            generator.specie_class(cross_bridge_on_bridges_base.name)
          end

          describe '#original' do
            it { expect(subject.original).to eq(original_specie) }
          end

          describe '#spec' do
            it { expect(subject.spec).to eq(original_specie.spec) }
          end

          describe '#anchors' do
            it { expect(subject.anchors).to eq(original_specie.spec.anchors) }
          end

          describe '#species' do
            it { expect(subject.species.map(&:spec)).to eq(parent_specs) }
          end

          describe '#<=>' do
            let(:base_specs) do
              [
                dept_bridge_base,
                dept_methyl_on_bridge_base,
                dept_cross_bridge_on_bridges_base,
                dept_three_bridges_base
              ]
            end

            let(:other) do
              original = generator.specie_class(dept_three_bridges_base.name)
              make_scope(original, original.spec.parents)
            end

            it { expect(subject <=> other).to eq(-1) }
            it { expect(other <=> subject).to eq(1) }

            it { expect([subject, other].shuffle.sort).to eq([subject, other]) }
          end

          describe 'methods dependent from atom of complex specie' do
            let(:atom) { cross_bridge_on_bridges_base.atom(:cm) }

            describe '#index' do
              it { expect(subject.index(atom)).to eq(0) }
            end

            describe 'atom properties users' do
              let(:props) { Organizers::AtomProperties.new(subject.spec, atom) }

              describe '#role' do
                let(:classifier) { generator.classifier }
                it { expect(subject.role(atom)).to eq(classifier.index(props)) }
              end

              describe '#properties_of' do
                it { expect(subject.properties_of(atom)).to eq(props) }
              end
            end

            describe '#anchor?' do
              it { expect(subject.anchor?(atom)).to be_truthy }
            end
          end

          describe '#none?' do
            it { expect(subject.none?).to be_falsey }
          end

          describe '#scope?' do
            it { expect(subject.scope?).to be_truthy }
          end
        end

      end
    end
  end
end
