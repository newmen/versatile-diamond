require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Instances

        describe UniqueReactant, type: :algorithm do
          include_context :unique_reactant_context

          describe '#original' do
            it { expect(subject.original).to be_a(Code::Specie) }
            it { expect(subject.original.spec).to eq(dept_unique_reactant) }
          end

          describe '#actual' do
            it { expect(subject.actual).to eq(subject.original) }
            it { expect(subject.actual.spec).to eq(subject.original.spec) }
          end

          describe '#spec' do
            it { expect(subject.spec.name).to eq(dept_unique_reactant.name) }
            it { expect(subject.spec).not_to eq(dept_unique_reactant) }
          end

          describe '#concept' do
            it { expect(subject.concept).to eq(vl_unique_reactant) }
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
                let(:classifier) { generator.classifier }
                let(:role) { classifier.index(props) }
                let(:props) { Organizers::AtomProperties.new(subject.spec, atom) }

                describe '#source_role' do
                  it { expect(subject.source_role(atom)).to eq(role) }
                end

                describe '#actual_role' do
                  it { expect(subject.actual_role(atom)).to eq(role) }
                end

                describe '#properties_of' do
                  it { expect(subject.properties_of(atom)).to eq(props) }
                end
              end

              describe '#anchor?' do
                it { expect(subject.anchor?(atom)).to eq(anchor) }
              end

              describe '#symmetric?' do
                before { subject.original.find_symmetries! }
                it { expect(subject.symmetric?(atom)).to be_falsey }
              end

              describe '#many?' do
                # because all checking atoms are no symmetric or no anchor
                it { expect(subject.many?(atom)).to be_falsey }
              end

              describe 'usages_num' do
                it { expect(subject.usages_num(atom)).to eq(1) }
              end
            end

            it_behaves_like :check_atom_methods do
              let(:atom) { cm }
              let(:index) { 0 }
              let(:anchor) { true }
            end

            it_behaves_like :check_atom_methods do
              let(:atom) { cb }
              let(:index) { 1 }
              let(:anchor) { true }
            end

            it_behaves_like :check_atom_methods do
              let(:atom) { cl }
              let(:index) { 2 }
              let(:anchor) { false }
            end

            it_behaves_like :check_atom_methods do
              let(:atom) { cr }
              let(:index) { 3 }
              let(:anchor) { false }
            end
          end

          describe '#var_name' do
            it { expect(subject.var_name).to eq('methylOnBridge') }
          end
        end

      end
    end
  end
end
