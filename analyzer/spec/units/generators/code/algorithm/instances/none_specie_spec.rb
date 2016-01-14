require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Instances

        describe NoneSpecie, type: :algorithm do
          subject { described_class.new(generator, specie) }
          let(:specie) { generator.specie_class(spec.name) }
          let(:spec) { dept_bridge_base }

          let(:base_specs) { [spec] }
          let(:specific_specs) { [] }
          let(:typical_reactions) { [] }
          let(:generator) do
            stub_generator(base_specs: base_specs,
                           specific_specs: specific_specs,
                           typical_reactions: typical_reactions)
          end

          describe '#original' do
            it { expect(subject.original).to eq(specie) }
          end

          describe '#spec' do
            it { expect(subject.spec).to eq(specie.spec) }
          end

          describe '<=>' do
            let(:base_specs) { [spec, other_spec] }
            let(:other_spec) { dept_methyl_on_bridge_base }
            let(:other_specie) { generator.specie_class(other_spec.name) }
            let(:other_instance) { described_class.new(generator, other_specie) }

            it { expect(subject <=> other_instance).to eq(1) }
            it { expect(other_instance <=> subject).to eq(-1) }

            it { expect([subject, other_instance].shuffle.sort).
              to eq([other_instance, subject]) }
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
                it { expect(subject.anchor?(atom)).to be_truthy }
              end

              describe '#symmetric?' do
                let(:specific_specs) { [dept_right_hydrogenated_bridge] }
                let(:typical_reactions) { [dept_hydrogen_abs_from_gap] }
                before { subject.original.find_symmetries! }
                it { expect(subject.symmetric?(atom)).to eq(symmetric) }
              end

              describe '#many?' do
                it { expect(subject.many?(atom)).to eq(many) }
              end
            end

            [:ct, :cr, :cl].each do |keyname|
              let(keyname) { specie.spec.spec.atom(keyname) }
            end

            it_behaves_like :check_atom_methods do
              let(:atom) { ct }
              let(:index) { 0 }
              let(:symmetric) { false }
              let(:many) { symmetric }
            end

            it_behaves_like :check_atom_methods do
              let(:atom) { cl }
              let(:index) { 1 }
              let(:symmetric) { true }
              let(:many) { symmetric }
            end

            it_behaves_like :check_atom_methods do
              let(:atom) { cr }
              let(:index) { 2 }
              let(:symmetric) { true }
              let(:many) { symmetric }
            end
          end

          describe '#none?' do
            it { expect(subject.none?).to be_truthy }
          end

          describe '#scope?' do
            it { expect(subject.scope?).to be_falsey }
          end

          describe '#var_name' do
            it { expect(subject.var_name).to eq('bridge') }
          end
        end

      end
    end
  end
end
