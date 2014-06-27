require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe Specie, use: :engine_generator do
        let(:empty_generator) { stub_generator({}) }

        describe '#class_name' do
          shared_examples_for :check_class_name do
            subject { described_class.new(empty_generator, dept_spec) }
            it { expect(subject.class_name).to eq(class_name) }
          end

          it_behaves_like :check_class_name do
            let(:dept_spec) { dept_hydrogen_ion }
            let(:class_name) { 'HydrogenHs' }
          end

          it_behaves_like :check_class_name do
            let(:dept_spec) { dept_bridge_base }
            let(:class_name) { 'Bridge' }
          end

          it_behaves_like :check_class_name do
            let(:dept_spec) { dept_activated_incoherent_bridge }
            let(:class_name) { 'BridgeCTsi' }
          end
        end

        describe '#enum_name' do
          shared_examples_for :check_enum_name do
            subject { described_class.new(empty_generator, dept_spec) }
            it { expect(subject.enum_name).to eq(enum_name) }
          end

          it_behaves_like :check_enum_name do
            let(:dept_spec) { dept_bridge_base }
            let(:enum_name) { 'BRIDGE' }
          end

          it_behaves_like :check_enum_name do
            let(:dept_spec) { dept_activated_incoherent_bridge }
            let(:enum_name) { 'BRIDGE_CTsi' }
          end
        end

        describe '#file_name' do
          shared_examples_for :check_file_name do
            subject { described_class.new(empty_generator, dept_spec) }
            it { expect(subject.file_name).to eq(file_name) }
          end

          it_behaves_like :check_file_name do
            let(:dept_spec) { dept_bridge_base }
            let(:file_name) { 'bridge' }
          end

          it_behaves_like :check_file_name do
            let(:dept_spec) { dept_cross_bridge_on_bridges_base }
            let(:file_name) { 'cross_bridge_on_bridges' }
          end
        end

        describe '#atoms_num' do
          let(:bases) { [dept_bridge_base, dept_dimer_base] }
          let(:specifics) { [dept_activated_dimer] }
          let(:generator) do
            stub_generator(base_specs: bases, specific_specs: specifics)
          end

          shared_examples_for :check_atoms_num do
            subject { generator.specie_class(dept_spec) }
            it { expect(subject.atoms_num).to eq(atoms_num) }
          end

          it_behaves_like :check_atoms_num do
            let(:dept_spec) { dept_bridge_base }
            let(:atoms_num) { 3 }
          end

          it_behaves_like :check_atoms_num do
            let(:dept_spec) { dept_dimer_base }
            let(:atoms_num) { 2 }
          end

          it_behaves_like :check_atoms_num do
            let(:dept_spec) { dept_activated_dimer }
            let(:atoms_num) { 1 }
          end
        end
      end

    end
  end
end
