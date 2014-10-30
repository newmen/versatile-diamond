require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe Specie, type: :code do
        let(:base_specs) { [] }
        let(:specific_specs) { [] }
        let(:generator) do
          stub_generator(base_specs: base_specs, specific_specs: specific_specs)
        end

        def code_for(base_spec)
          generator.specie_class(base_spec.name)
        end

        describe '#spec' do
          it { expect(code_bridge_base.spec).to eq(dept_bridge_base) }
        end

        describe '#original' do
          it { expect(code_bridge_base.original).to be_a(OriginalSpecie) }
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

          it_behaves_like :check_class_name do
            subject { code_cross_bridge_on_bridges_base }
            let(:class_name) { 'CrossBridgeOnBridges' }
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
            subject { code_for(dept_spec) }
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

        describe '#wrapped_base_class_name' do
          before { generator }

          shared_examples_for :parent_bridge_name do
            subject { code_for(bridge_base) }
            let(:pb_name) { 'Base<SourceSpec<ParentSpec, 3>, BRIDGE, 3>' }
            it { expect(subject.wrapped_base_class_name).to eq(pb_name) }
          end

          describe 'empty base specie' do
            let(:base_specs) { [dept_bridge_base] }
            let(:name) { 'Base<SourceSpec<BaseSpec, 3>, BRIDGE, 3>' }
            it { expect(code_for(bridge_base).wrapped_base_class_name).to eq(name) }

            describe '#base_class_names' do
              let(:base_class_names) { [name, 'DiamondAtomsIterator'] }
              it { expect(code_for(bridge_base).base_class_names).
                to eq(base_class_names) }
            end
          end

          describe 'only one child spec' do
            let(:base_specs) { [dept_bridge_base, dept_methyl_on_bridge_base] }

            it_behaves_like :parent_bridge_name

            describe 'child base specie' do
              subject { code_for(methyl_on_bridge_base) }
              let(:base_class_names) { [name] }
              let(:name) do
                'Base<AdditionalAtomsWrapper<DependentSpec<BaseSpec, 1>, 1>, ' \
                  'METHYL_ON_BRIDGE, 2>'
              end
              it { expect(subject.wrapped_base_class_name).to eq(name) }
              it { expect(subject.base_class_names).to eq(base_class_names) }
            end
          end

          describe 'multi same spec' do
            let(:base_specs) { [dept_bridge_base, dept_dimer_base] }

            it_behaves_like :parent_bridge_name

            describe 'child base specie' do
              let(:base_class_names) { [name, 'DiamondAtomsIterator'] }
              let(:name) { 'Base<DependentSpec<BaseSpec, 2>, DIMER, 2>' }
              it { expect(code_for(dimer_base).wrapped_base_class_name).to eq(name) }
              it { expect(code_for(dimer_base).base_class_names).
                to eq(base_class_names) }
            end
          end

          describe 'specific parent specie' do
            pending 'asdf'
          end

          describe 'specific leaf specie' do
            pending 'asdf'
          end
        end

        describe '#outer_base_name' do
          it { expect(code_bridge_base.outer_base_name).to eq('base') }
        end

        describe '#full_file_path' do
          let(:ffp) { 'species/bases/bridge.h' }
          it { expect(code_bridge_base.full_file_path.to_s).to eq(ffp) }
        end

        describe '#symmetric?' do
          describe 'bridges' do
            let(:base_specs) { [dept_bridge_base] }
            let(:specific_specs) { [dept_right_hydrogenated_bridge] }
            it { expect(code_for(bridge_base).symmetric?).to be_truthy }
            it { expect(code_for(right_hydrogenated_bridge).symmetric?).to be_falsey }
          end

          describe 'dimers' do
            let(:base_specs) { [dept_bridge_base, dept_dimer_base] }
            let(:specific_specs) { [dept_activated_bridge, dept_activated_dimer] }
            it { expect(code_for(bridge_base).symmetric?).to be_falsey }
            it { expect(code_for(dimer_base).symmetric?).to be_truthy }
            it { expect(code_for(activated_dimer).symmetric?).to be_falsey }
          end

          describe 'two symmetric dimer' do
            let(:base_specs) { [dept_dimer_base] }
            let(:specific_specs) do
              [dept_activated_dimer, dept_bottom_hydrogenated_activated_dimer]
            end
            it { expect(code_for(dimer_base).symmetric?).to be_truthy }
            it { expect(code_for(activated_dimer).symmetric?).to be_truthy }

            let(:bhad) { code_for(bottom_hydrogenated_activated_dimer) }
            it { expect(bhad.symmetric?).to be_falsey }
          end
        end

        describe '#find_root?' do
          let(:base_specs) { [dept_bridge_base, dept_dimer_base] }
          let(:specific_specs) { [dept_activated_bridge, dept_activated_dimer] }

          it { expect(code_for(bridge_base).find_root?).to be_truthy }
          it { expect(code_for(dimer_base).find_root?).to be_truthy }
          it { expect(code_for(activated_bridge).find_root?).to be_falsey }
          it { expect(code_for(activated_dimer).find_root?).to be_falsey }
        end

        describe '#header_parents_dependencies' do
          let(:base_specs) { [dept_bridge_base, dept_dimer_base] }
          let(:specific_specs) { [dept_activated_dimer] }

          it { expect(code_for(bridge_base).header_parents_dependencies).to be_empty }
          it { expect(code_for(dimer_base).header_parents_dependencies).to be_empty }
          it { expect(code_for(activated_dimer).header_parents_dependencies).
            to eq([code_for(dimer_base)]) }
        end

        describe '#non_root_children' do
          let(:base_specs) do
            [dept_bridge_base, dept_dimer_base, dept_methyl_on_bridge_base]
          end
          let(:specific_specs) { [dept_activated_dimer] }

          shared_examples_for :check_non_root_children do
            let(:code_specie) { code_for(subject) }
            let(:code_childs) { children.map(&method(:code_for)) }
            it { expect(code_specie.non_root_children). to match_array(code_childs) }
          end

          it_behaves_like :check_non_root_children do
            subject { bridge_base }
            let(:children) { [methyl_on_bridge_base] }
          end

          it_behaves_like :check_non_root_children do
            subject { dimer_base }
            let(:children) { [activated_dimer] }
          end

          %w(methyl_on_bridge_base activated_dimer).each do |var_name|
            it_behaves_like :check_non_root_children do
              subject { send(var_name.to_sym) }
              let(:children) { [] }
            end
          end
        end

        describe '#print_name' do
          it { expect(code_bridge_base.print_name).to eq('bridge') }
          it { expect(code_activated_bridge.print_name).to eq('bridge(ct: *)') }
        end
      end

    end
  end
end
