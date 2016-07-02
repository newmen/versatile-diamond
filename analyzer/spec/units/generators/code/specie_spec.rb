require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe Specie, type: :code do
        let(:base_specs) { [] }
        let(:specific_specs) { [] }
        let(:ubiquitous_reactions) { [] }
        let(:typical_reactions) { [] }
        let(:lateral_reactions) { [] }
        let(:generator) do
          stub_generator(
            base_specs: base_specs,
            specific_specs: specific_specs,
            ubiquitous_reactions: ubiquitous_reactions,
            typical_reactions: typical_reactions,
            lateral_reactions: lateral_reactions)
        end

        let(:classifier) { generator.classifier }

        describe '#spec' do
          it { expect(code_bridge_base.spec).to eq(dept_bridge_base) }
        end

        describe '#original' do
          it { expect(code_bridge_base.original).to be_a(OriginalSpecie) }
        end

        describe 'default symmetric atoms' do
          let(:ct) { bridge_base.atom(:ct) }

          describe '#symmetric_atom?' do
            it { expect(code_bridge_base.symmetric_atom?(ct)).to be_falsey }
          end

          describe '#symmetric_atoms' do
            it { expect(code_bridge_base.symmetric_atoms(ct)).to be_empty }
          end
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
            subject { specie_class(dept_spec) }
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
          before do
            generator
            subject.find_symmetries!
          end

          shared_examples_for :parent_bridge_name do
            let(:parent_bridge) { specie_class(bridge_base) }
            let(:pb_name) { 'Base<SourceSpec<ParentSpec, 3>, BRIDGE, 3>' }
            it { expect(parent_bridge.wrapped_base_class_name).to eq(pb_name) }
          end

          shared_examples_for :check_classes_names do
            it { expect(subject.wrapped_base_class_name).to eq(name) }
            it { expect(subject.base_class_names).to eq(base_class_names) }
          end

          describe 'empty base specie' do
            subject { specie_class(bridge_base) }
            let(:base_specs) { [dept_bridge_base] }

            it_behaves_like :check_classes_names do
              let(:base_class_names) { [name, 'DiamondAtomsIterator'] }
              let(:name) { 'Base<SourceSpec<BaseSpec, 3>, BRIDGE, 3>' }
            end
          end

          describe 'not reactant specie with one child' do
            subject { specie_class(methyl_on_bridge_base) }
            let(:base_specs) { [dept_bridge_base, dept_methyl_on_bridge_base] }
            let(:typical_reactions) { [dept_methyl_activation] }

            it_behaves_like :parent_bridge_name
            it_behaves_like :check_classes_names do
              let(:base_class_names) { [name] }
              let(:name) do
                'Base<AdditionalAtomsWrapper<DependentSpec<ParentSpec, 1>, 1>, METHYL_ON_BRIDGE, 2>'
              end
            end
          end

          describe 'no children reactant specie' do
            subject { specie_class(hydrogenated_methyl_on_bridge) }
            let(:base_specs) { [dept_bridge_base, dept_methyl_on_bridge_base] }
            let(:typical_reactions) { [dept_methyl_activation] }

            it_behaves_like :parent_bridge_name
            it_behaves_like :check_classes_names do
              let(:base_class_names) { [name] }
              let(:name) do
                'Specific<Base<DependentSpec<BaseSpec, 1>, METHYL_ON_BRIDGE_CMH, 1>>'
              end
            end
          end

          describe 'local reactant specie' do
            subject { specie_class(hydrogenated_methyl_on_bridge) }
            let(:base_specs) { [dept_bridge_base, dept_methyl_on_bridge_base] }
            let(:ubiquitous_reactions) { [dept_surface_activation] }
            let(:typical_reactions) { [dept_methyl_activation] }

            it_behaves_like :parent_bridge_name
            it_behaves_like :check_classes_names do
              let(:base_class_names) { [name] }
              let(:cmix) { subject.index(subject.spec.spec.atom(:cm)) }
              let(:name) do
                "Base<LocalableRole<DependentSpec<BaseSpec, 1>, #{cmix}>, METHYL_ON_BRIDGE_CMH, 1>"
              end
            end
          end

          describe 'sidepiece and multi child specie' do
            subject { specie_class(dimer_base) }
            let(:base_specs) { [dept_dimer_base] }
            let(:lateral_reactions) { [dept_middle_lateral_df] }

            it_behaves_like :parent_bridge_name
            it_behaves_like :check_classes_names do
              let(:base_class_names) { [name, 'DiamondAtomsIterator'] }
              let(:name) { 'Sidepiece<Base<DependentSpec<BaseSpec, 2>, DIMER, 2>>' }
            end
          end

          describe 'specific specie' do
            shared_examples_for :check_activated_bridge do
              let(:specific_specs) { [dept_extra_activated_bridge] }
              let(:typical_reactions) { [dept_dimer_formation] }

              it_behaves_like :parent_bridge_name
              it_behaves_like :check_classes_names do
                let(:base_class_names) { [name] }
              end
            end

            it_behaves_like :check_activated_bridge do
              subject { specie_class(activated_bridge) }
              let(:name) do
                'Specific<Base<DependentSpec<ParentSpec, 1>, BRIDGE_CTs, 1>>'
              end
            end

            it_behaves_like :check_activated_bridge do
              subject { specie_class(extra_activated_bridge) }
              let(:name) { 'Base<DependentSpec<BaseSpec, 1>, BRIDGE_CTss, 1>' }
            end
          end

          describe 'symmetric specie' do
            let(:typical_reactions) { [dept_sierpinski_drop] }

            it_behaves_like :check_classes_names do
              subject { specie_class(cross_bridge_on_bridges_base) }
              let(:name) { 'Specific<Base<DependentSpec<ParentSpec, 2>, ' \
                'CROSS_BRIDGE_ON_BRIDGES, 3>>' }
              let(:base_class_names) do
                [
                  'Symmetric<OriginalCrossBridgeOnBridges, ' \
                    'SymmetricCrossBridgeOnBridges>',
                  'DiamondAtomsIterator'
                ]
              end
            end
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
            let(:typical_reactions) { [dept_hydrogen_abs_from_gap] }
            it { expect(specie_class(bridge_base).symmetric?).to be_truthy }

            let(:dept_rhb) { specie_class(right_hydrogenated_bridge) }
            it { expect(dept_rhb.symmetric?).to be_falsey }
          end

          describe 'dimers' do
            let(:base_specs) { [dept_bridge_base, dept_dimer_base] }
            let(:typical_reactions) { [dept_dimer_formation, dept_hydrogen_migration] }
            it { expect(specie_class(bridge_base).symmetric?).to be_falsey }
            it { expect(specie_class(dimer_base).symmetric?).to be_truthy }
            it { expect(specie_class(activated_dimer).symmetric?).to be_falsey }
          end

          describe 'two symmetric dimer' do
            let(:base_specs) { [dept_dimer_base] }
            let(:specific_specs) do
              [dept_activated_dimer, dept_bottom_hydrogenated_activated_dimer]
            end
            let(:typical_reactions) { [dept_hydrogen_migration, dept_bhad_activation] }
            it { expect(specie_class(dimer_base).symmetric?).to be_truthy }
            it { expect(specie_class(activated_dimer).symmetric?).to be_truthy }

            let(:bhad) { specie_class(bottom_hydrogenated_activated_dimer) }
            it { expect(bhad.symmetric?).to be_falsey }
          end
        end

        describe 'rise and endpoint' do
          let(:base_specs) { [dept_bridge_base, dept_dimer_base] }
          let(:specific_specs) do
            [dept_activated_incoherent_bridge, dept_activated_dimer]
          end
          let(:typical_reactions) { [dept_dimer_formation, dept_hydrogen_migration] }

          describe '#find_root?' do
            it { expect(specie_class(bridge_base).find_root?).to be_truthy }
            it { expect(specie_class(dimer_base).find_root?).to be_truthy }
            it { expect(specie_class(activated_dimer).find_root?).to be_falsey }
            it { expect(specie_class(activated_incoherent_bridge).find_root?).
              to be_falsey }
          end

          describe '#find_endpoint?' do
            it { expect(specie_class(bridge_base).find_endpoint?).to be_falsey }
            it { expect(specie_class(dimer_base).find_endpoint?).to be_falsey }
            it { expect(specie_class(activated_dimer).find_endpoint?).to be_truthy }
            it { expect(specie_class(activated_incoherent_bridge).find_endpoint?).
              to be_truthy }
          end
        end

        describe '#header_parents_dependencies' do
          let(:base_specs) { [dept_bridge_base, dept_dimer_base] }
          let(:specific_specs) { [dept_activated_dimer] }

          it { expect(specie_class(bridge_base).header_parents_dependencies).
            to be_empty }
          it { expect(specie_class(dimer_base).header_parents_dependencies).
            to be_empty }
          it { expect(specie_class(activated_dimer).header_parents_dependencies).
            to eq([specie_class(dimer_base)]) }
        end

        describe '#index' do
          describe 'top atom of bridge' do
            it { expect(code_bridge_base.index(bridge_base.atom(:ct))).to eq(0) }
          end

          describe 'atoms of methyl on bridge' do
            subject { code_methyl_on_bridge_base }
            it { expect(subject.index(methyl_on_bridge_base.atom(:cm))).to eq(0) }
            it { expect(subject.index(methyl_on_bridge_base.atom(:cb))).to eq(1) }
          end
        end

        describe '#role' do
          before { classifier.analyze!(subject.spec) }

          subject { code_bridge_base }
          it { expect(subject.role(bridge_base.atom(:ct))).to eq(0) }

          let(:first) { subject.role(bridge_base.atom(:cr)) }
          let(:second) { subject.role(bridge_base.atom(:cl)) }
          it { expect(first == second).to be_truthy }
          it { expect(first != 0).to be_truthy }
        end

        describe '#print_name' do
          it { expect(code_bridge_base.print_name).to eq('bridge') }
          it { expect(code_activated_bridge.print_name).to eq('bridge(ct: *)') }
        end
      end

    end
  end
end
