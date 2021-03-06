require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Instances

        describe UniqueParent, type: :algorithm do
          include_context :unique_parent_context

          shared_context :with_other_proxy do
            let(:specific_specs) { [more_complex] }
            let(:more_complex) { dept_activated_methyl_on_bridge }
            let(:other_proxy) { more_complex.parents.first }
            let(:other) { described_class.new(generator, other_proxy) }
          end

          describe '#original' do
            it { expect(subject.original).to be_a(Code::Specie) }
            it { expect(subject.original.spec).to eq(dept_bridge_base) }
          end

          describe '#actual' do
            it { expect(subject.actual).to be_a(Code::Specie) }
            it { expect(subject.actual.spec.spec).to eq(methyl_on_bridge_base) }
          end

          describe '#spec' do
            it { expect(subject.spec).to eq(dept_uniq_parent) }
            it { expect(subject.spec).not_to eq(dept_uniq_specie) }
          end

          describe '#symmetric_atoms' do
            it { expect(subject.symmetric_atoms(cb)).to be_empty }

            describe 'realy symmetric' do
              let(:base_specs) { [dept_bridge_base] }
              let(:specific_specs) { [dept_uniq_specie] }
              let(:typical_reactions) { [dept_hydrogen_abs_from_gap] }
              let(:dept_uniq_specie) { dept_right_hydrogenated_bridge }
              it { expect(subject.symmetric_atoms(cr)).to match_array([cr, cl]) }
              it { expect(subject.symmetric_atoms(cl)).to match_array([cr, cl]) }
            end
          end

          describe '#<=>' do
            include_context :with_other_proxy

            it { expect(subject <=> other).to eq(1) }
            it { expect(other <=> subject).to eq(-1) }

            it { expect([subject, other].shuffle.sort).to eq([other, subject]) }
          end

          describe 'methods dependent from atom of complex specie' do
            describe '#index' do
              it { expect(subject.index(cb)).to eq(0) }
              it { expect { subject.index(cm) }.to raise_error }
            end

            describe 'atom properties users' do
              let(:classifier) { generator.classifier }

              describe 'from original specie' do
                let(:ct) { bridge_base.atom(:ct) }
                let(:props) { Organizers::AtomProperties.new(dept_bridge_base, ct) }

                describe '#source_role' do
                  it { expect(subject.source_role(cb)).to eq(classifier.index(props)) }
                  it { expect { subject.original_role(cm) }.to raise_error }
                end

                describe '#properties_of' do
                  it { expect(subject.properties_of(cb)).to eq(props) }
                  it { expect { subject.properties_of(cm) }.to raise_error }
                end
              end

              describe '#actual_role' do
                let(:props) { Organizers::AtomProperties.new(dept_uniq_specie, cb) }
                it { expect(subject.actual_role(cb)).to eq(classifier.index(props)) }
                it { expect { subject.actual_role(cm) }.not_to raise_error }
              end
            end

            describe '#actual_anchor?' do
              it { expect(subject.actual_anchor?(cb)).to be_truthy }
              it { expect(subject.actual_anchor?(cm)).to be_truthy }
              it { expect(subject.actual_anchor?(cr)).to be_falsey }
            end

            describe '#anchor?' do
              it { expect(subject.anchor?(cb)).to be_truthy }
              it { expect(subject.anchor?(cm)).to be_falsey }
            end

            describe '#atom?' do
              it { expect(subject.atom?(cb)).to be_truthy }
              it { expect(subject.atom?(cm)).to be_falsey }
            end

            describe '#symmetric?' do
              before { subject.original.find_symmetries! }
              it { expect(subject.symmetric?(cb)).to be_falsey }
              it { expect(subject.symmetric?(cm)).to be_falsey }
            end

            describe '#many?' do
              it { expect(subject.many?(cb)).to be_falsey }
            end

            describe '#usages_num' do
              it { expect(subject.usages_num(cb)).to eq(1) }
            end

            describe '#common_atoms_with' do
              include_context :with_other_proxy
              let(:pairs) do
                [
                  [cb, other.spec.spec.atom(:cb)],
                  [cr, other.spec.spec.atom(:cr)],
                  [cl, other.spec.spec.atom(:cl)]
                ]
              end

              it { expect(subject.common_atoms_with(other)).to match_array(pairs) }
            end
          end

          describe '#none?' do
            it { expect(subject.none?).to be_falsey }
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
