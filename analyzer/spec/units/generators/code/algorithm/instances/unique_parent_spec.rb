require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Instances

        describe UniqueParent, type: :algorithm do
          def make_proxy(parent, complex)
            mirror = Mcs::SpeciesComparator.make_mirror(complex, parent)
            Organizers::ProxyParentSpec.new(parent, complex, mirror)
          end

          subject { described_class.new(generator, proxy_dept_spec) }

          let(:base_specs) { [dept_bridge_base, complex] }
          let(:specific_specs) { [] }
          let(:generator) do
            stub_generator(base_specs: base_specs, specific_specs: specific_specs)
          end

          let(:veiled_bridge) { Concepts::VeiledSpec.new(bridge_base) }
          let(:parent) { dept_bridge_base.clone_with_replace(veiled_bridge) }
          let(:complex) { dept_methyl_on_bridge_base }
          let(:proxy_dept_spec) { make_proxy(parent, complex) }

          describe '#original' do
            it { expect(subject.original).to be_a(Code::Specie) }
            it { expect(subject.original.spec).to eq(dept_bridge_base) }
          end

          describe '#spec' do
            it { expect(subject.spec.name).to eq(parent.name) }
            it { expect(subject.spec).not_to eq(parent) }
            it { expect(subject.spec).not_to eq(complex) }
          end

          describe '#concept' do
            it { expect(subject.concept).to eq(veiled_bridge) }
          end

          describe '#<=>' do
            let(:specific_specs) { [more_complex] }
            let(:more_complex) { dept_activated_methyl_on_bridge }
            let(:other_proxy) { make_proxy(more_complex, complex) }
            let(:other) { described_class.new(generator, other_proxy) }

            it { expect(subject <=> other).to eq(1) }
            it { expect(other <=> subject).to eq(-1) }

            it { expect([subject, other].shuffle.sort).to eq([other, subject]) }
          end

          describe 'methods dependent from atom of complex specie' do
            let(:cb) { complex.spec.atom(:cb) }
            let(:cm) { complex.spec.atom(:cm) }

            describe '#index' do
              it { expect(subject.index(cb)).to eq(0) }
              it { expect(subject.index(cm)).to be_nil }
            end

            describe 'atom properties users' do
              let(:vb_ct) { veiled_bridge.atom(:ct) }
              let(:props) { Organizers::AtomProperties.new(parent, vb_ct) }

              describe '#role' do
                let(:classifier) { generator.classifier }
                it { expect(subject.role(cb)).to eq(classifier.index(props)) }
                it { expect { subject.role(cm) }.to raise_error }
              end

              describe '#properties_of' do
                it { expect(subject.properties_of(cb)).to eq(props) }
                it { expect { subject.properties_of(cm) }.to raise_error }
              end
            end

            describe '#anchor?' do
              it { expect(subject.anchor?(cb)).to be_truthy }
              it { expect(subject.anchor?(cm)).to be_falsey }
            end

            describe '#symmetric?' do
              before { subject.original.find_symmetries! }
              it { expect(subject.symmetric?(cb)).to be_falsey }
              it { expect(subject.symmetric?(cm)).to be_falsey }
            end

            describe '#many?' do
              it { expect(subject.many?(cb)).to be_falsey }
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
        end

      end
    end
  end
end
