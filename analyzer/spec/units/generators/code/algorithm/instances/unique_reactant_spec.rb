require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Instances

        describe UniqueReactant, type: :algorithm do
          include_context :unique_reactant_context

          shared_context :with_other_proxy do
            let(:specific_specs) { [complex] }
            let(:complex) { dept_activated_methyl_on_bridge }
            let(:other) { described_class.new(generator, complex.spec) }
          end

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

          describe '#symmetric_atoms' do
            let(:base_specs) { [dept_bridge_base] }
            let(:specific_specs) { [dept_unique_reactant] }
            let(:typical_reactions) { [dept_hydrogen_abs_from_gap] }
            let(:dept_unique_reactant) { dept_right_hydrogenated_bridge }

            it { expect(subject.symmetric_atoms(ct)).to be_empty }
            it { expect(subject.symmetric_atoms(cr)).to be_empty }
            it { expect(subject.symmetric_atoms(cl)).to be_empty }
          end

          describe '#<=>' do
            include_context :with_other_proxy

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

              describe '#actual_anchor?' do
                it { expect(subject.actual_anchor?(atom)).to eq(anchor) }
              end

              describe '#anchor?' do
                it { expect(subject.anchor?(atom)).to eq(anchor) }
              end

              describe '#atom?' do
                it { expect(subject.atom?(atom)).to be_truthy }
              end

              describe '#symmetric?' do
                before { subject.original.find_symmetries! }
                it { expect(subject.symmetric?(atom)).to be_falsey }
              end

              describe '#many?' do
                # because all checking atoms are no symmetric or no anchor
                it { expect(subject.many?(atom)).to be_falsey }
              end

              describe '#usages_num' do
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

            describe '#common_atoms_with' do
              include_context :with_other_proxy
              let(:pairs) do
                [
                  [cm, other.spec.spec.atom(:cm)],
                  [cb, other.spec.spec.atom(:cb)],
                  [cr, other.spec.spec.atom(:cr)],
                  [cl, other.spec.spec.atom(:cl)]
                ]
              end

              it { expect(subject.common_atoms_with(other)).to match_array(pairs) }
            end
          end

          describe '#var_name' do
            it { expect(subject.var_name).to eq('methylOnBridge') }
          end

          describe '#symmetric_var_name' do
            it { expect(subject.symmetric_var_name).to eq('symmetricMethylOnBridge') }
          end
        end

      end
    end
  end
end
