require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Instances

        describe UniqueReactant, type: :algorithm do
          subject { described_class.new(generator, veiled_spec) }

          let(:base_specs) { [dept_bridge_base, original] }
          let(:specific_specs) { [] }
          let(:generator) do
            stub_generator(base_specs: base_specs, specific_specs: specific_specs)
          end

          let(:original) { dept_methyl_on_bridge_base }
          let(:concept_spec) { original.spec }
          let(:veiled_spec) { Concepts::VeiledSpec.new(concept_spec) }

          USING_KEYNAMES = [:cm, :cb, :cr, :cl].freeze
          let(:atoms) { USING_KEYNAMES.map { |keyname| veiled_spec.atom(keyname) } }
          USING_KEYNAMES.each_with_index do |keyname, i|
            let(:"v_#{keyname}") { atoms[i] }
          end

          describe '#original' do
            it { expect(subject.original).to be_a(Code::Specie) }
            it { expect(subject.original.spec).to eq(original) }
          end

          describe '#spec' do
            it { expect(subject.spec.name).to eq(original.name) }
            it { expect(subject.spec).not_to eq(original) }
          end

          describe '#concept' do
            it { expect(subject.concept).to eq(veiled_spec) }
          end

          describe '#anchors' do
            it { expect(subject.anchors).to match_array([v_cm, v_cb]) }
          end

          describe '#<=>' do
            let(:specific_specs) { [complex] }
            let(:complex) { dept_activated_methyl_on_bridge }
            let(:other) { described_class.new(generator, complex.spec) }

            it { expect(subject <=> other).to eq(1) }
            it { expect(other <=> subject).to eq(-1) }

            it { expect([subject, other].shuffle.sort).to eq([other, subject]) }
          end

          describe 'methods dependent from atom of complex specie' do
            shared_examples_for :check_atom_methods do
              describe '#index' do
                it { expect(subject.index(atom)).to eq(index) }
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
                it { expect(subject.anchor?(atom)).to eq(anchor) }
              end
            end

            it_behaves_like :check_atom_methods do
              let(:atom) { v_cm }
              let(:index) { 0 }
              let(:anchor) { true }
            end

            it_behaves_like :check_atom_methods do
              let(:atom) { v_cb }
              let(:index) { 1 }
              let(:anchor) { true }
            end

            it_behaves_like :check_atom_methods do
              let(:atom) { v_cl }
              let(:index) { 2 }
              let(:anchor) { false }
            end

            it_behaves_like :check_atom_methods do
              let(:atom) { v_cr }
              let(:index) { 3 }
              let(:anchor) { false }
            end
          end
        end

      end
    end
  end
end
