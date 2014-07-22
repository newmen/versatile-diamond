require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe Specie, type: :code do
        describe '#spec' do
          it { expect(code_bridge_base.spec).to eq(dept_bridge_base) }
        end

        describe '#template_name' do
          it { expect(code_bridge_base.template_name).to eq('specie') }
        end

        describe '#define_name' do
          shared_examples_for :check_define_name do
            it { expect(subject.define_name).to eq(define_name) }
          end

          it_behaves_like :check_define_name do
            subject { code_bridge_base }
            let(:define_name) { 'BRIDGE_H' }
          end

          it_behaves_like :check_define_name do
            subject { code_activated_incoherent_bridge }
            let(:define_name) { 'BRIDGE_CTSI_H' }
          end

          it_behaves_like :check_define_name do
            subject { code_activated_methyl_on_incoherent_bridge }
            let(:define_name) { 'METHYL_ON_BRIDGE_CBI_CMS_H' }
          end
        end

        describe '#file_name' do
          shared_examples_for :check_file_name do
            it { expect(subject.file_name).to eq(file_name) }
          end

          it_behaves_like :check_file_name do
            subject { code_activated_methyl_on_incoherent_bridge }
            let(:file_name) { 'methyl_on_bridge_cbi_cms' }
          end

          it_behaves_like :check_file_name do
            subject { code_cross_bridge_on_bridges_base }
            let(:file_name) { 'cross_bridge_on_bridges' }
          end
        end

        describe '#class_name' do
          shared_examples_for :check_class_name do
            it { expect(subject.class_name).to eq(class_name) }
          end

          it_behaves_like :check_class_name do
            subject { code_hydrogen_ion }
            let(:class_name) { 'HydrogenHs' }
          end

          it_behaves_like :check_class_name do
            subject { code_bridge_base }
            let(:class_name) { 'Bridge' }
          end

          it_behaves_like :check_class_name do
            subject { code_activated_incoherent_bridge }
            let(:class_name) { 'BridgeCTsi' }
          end
        end

        describe '#enum_name' do
          shared_examples_for :check_enum_name do
            it { expect(subject.enum_name).to eq(enum_name) }
          end

          it_behaves_like :check_enum_name do
            subject { code_bridge_base }
            let(:enum_name) { 'BRIDGE' }
          end

          it_behaves_like :check_enum_name do
            subject { code_activated_incoherent_bridge }
            let(:enum_name) { 'BRIDGE_CTsi' }
          end
        end

        describe '#atoms_num' do
          let(:bases) { [dept_bridge_base, dept_dimer_base] }
          let(:specifics) { [dept_activated_dimer] }
          let(:generator) do
            stub_generator(base_specs: bases, specific_specs: specifics)
          end

          shared_examples_for :check_atoms_num do
            subject { generator.specie_class(dept_spec.name) }
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

        # describe '#symmetric?' do
        #   def sc(name)
        #     generator.specie_class(name)
        #   end

        #   let(:all_species) { bases + specifics }
        #   let(:generator) do
        #     stub_generator(base_specs: bases, specific_specs: specifics)
        #   end

        #   before do
        #     all_species.each { |spec| sc(spec.name).find_self_symmetrics! }
        #   end

        #   describe 'bridges' do
        #     let(:bases) { [dept_bridge_base] }
        #     let(:specifics) { [dept_right_hydrogenated_bridge] }
        #     it { expect(sc(:bridge).symmetric?).to be_truthy }
        #     it { expect(sc(:'bridge(cr: H)').symmetric?).to be_falsey }
        #   end

        #   describe 'dimers' do
        #     let(:bases) { [dept_bridge_base, dept_dimer_base] }
        #     let(:specifics) do
        #       [dept_activated_dimer, dept_bottom_hydrogenated_activated_dimer]
        #     end
        #     it { expect(sc(:bridge).symmetric?).to be_falsey }
        #     it { expect(sc(:dimer).symmetric?).to be_truthy }
        #     it { expect(sc(:'dimer(cr: *)').symmetric?).to be_truthy }
        #     it { expect(sc(:'dimer(clb: H, cr: *)').symmetric?).to be_falsey }
        #   end
        # end
      end

    end
  end
end
