require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Instances

        describe SpeciesScope, type: :algorithm do
          def make_scope(original, proxy_specs)
            uniqs = proxy_specs.map { |spec| UniqueParent.new(generator, spec) }
            described_class.new(original, uniqs)
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

            it { expect(subject <=> other).to eq(1) }
            it { expect(other <=> subject).to eq(-1) }

            it { expect([subject, other].shuffle.sort).to eq([other, subject]) }
          end

          describe '#anchor?' do
            shared_examples_for :check_anchors do
              let(:original_specie) { generator.specie_class(concept_spec.name) }
              it 'check anchors hash' do
                anchors.each do |keyname, result|
                  expect(subject.anchor?(concept_spec.atom(keyname))).to be_truthy
                end
              end
            end

            it_behaves_like :check_anchors do
              let(:concept_spec) { cross_bridge_on_bridges_base }
              let(:anchors) { [:cm, :ctl, :ctr] }
            end

            it_behaves_like :check_anchors do
              let(:base_specs) do
                [
                  dept_bridge_base,
                  dept_dimer_base,
                  dept_methyl_on_bridge_base,
                  dept_methyl_on_dimer_base,
                  dept_intermed_migr_down_common_base
                ]
              end
              let(:concept_spec) { intermed_migr_down_common_base }
              let(:anchors) { [:cm, :cbr, :cdr] }
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
