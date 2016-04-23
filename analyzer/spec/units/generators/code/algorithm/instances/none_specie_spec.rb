require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Instances

        describe NoneSpecie, type: :algorithm do
          include_context :none_specie_context

          shared_context :with_other_proxy do
            let(:base_specs) { [dept_none_specie, other_spec] }
            let(:other_spec) { dept_methyl_on_bridge_base }
            let(:other_specie) { generator.specie_class(other_spec.name) }
            let(:other) { described_class.new(generator, other_specie) }
          end

          describe '#original' do
            it { expect(subject.original).to eq(orig_none_specie) }
          end

          describe '#actual' do
            it { expect(subject.actual).to eq(orig_none_specie) }
          end

          describe '#spec' do
            it { expect(subject.spec).to eq(orig_none_specie.spec) }
          end

          describe '#symmetric_atoms' do
            let(:base_specs) { [dept_bridge_base] }
            let(:specific_specs) { [dept_right_hydrogenated_bridge] }
            let(:typical_reactions) { [dept_hydrogen_abs_from_gap] }

            it { expect(subject.symmetric_atoms(ct)).to be_empty }
            it { expect(subject.symmetric_atoms(cr)).to match_array([cr, cl]) }
            it { expect(subject.symmetric_atoms(cl)).to match_array([cr, cl]) }
          end

          describe '<=>' do
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

              describe '#anchor?' do
                it { expect(subject.anchor?(atom)).to be_truthy }
              end

              describe '#atom?' do
                it { expect(subject.atom?(atom)).to be_truthy }
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

              describe '#usages_num' do
                it { expect(subject.usages_num(atom)).to eq(used_times) }
              end
            end

            it_behaves_like :check_atom_methods do
              let(:atom) { ct }
              let(:index) { 0 }
              let(:symmetric) { false }
              let(:many) { symmetric }
              let(:used_times) { 1 }
            end

            it_behaves_like :check_atom_methods do
              let(:atom) { cl }
              let(:index) { 1 }
              let(:symmetric) { true }
              let(:many) { symmetric }
              let(:used_times) { 2 }
            end

            it_behaves_like :check_atom_methods do
              let(:atom) { cr }
              let(:index) { 2 }
              let(:symmetric) { true }
              let(:many) { symmetric }
              let(:used_times) { 2 }
            end

            describe '#common_atoms_with' do
              include_context :with_other_proxy
              let(:pairs) do
                [
                  [ct, other.spec.spec.atom(:cb)],
                  [cr, other.spec.spec.atom(:cr)],
                  [cl, other.spec.spec.atom(:cl)]
                ]
              end

              it { expect(subject.common_atoms_with(other)).to match_array(pairs) }
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

          describe '#symmetric_var_name' do
            it { expect(subject.symmetric_var_name).to eq('symmetricBridge') }
          end
        end

      end
    end
  end
end
