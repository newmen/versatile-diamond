require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe SymmetriesDetector, use: :engine_generator do
        let(:typical_reactions) { [] }

        shared_examples_for :check_symmetry do
          let(:detector) { generator.detectors_cacher.get(subject) }
          let(:generator) do
            stub_generator(
              base_specs: bases,
              specific_specs: specifics,
              typical_reactions: typical_reactions)
          end

          before { generator }

          it '#symmetry_classes' do
            scns = detector.symmetry_classes.map(&:base_class_name)
            expect(scns).to match_array(symmetry_classes)
          end

          it 'check keynames of symmetric atoms' do
            concept = subject.spec
            atoms = concept.links.keys
            symmetric_atoms = atoms.select { |a| detector.symmetric_atom?(a) }
            keynames = symmetric_atoms.map { |a| concept.keyname(a) }
            expect(keynames).to match_array(symmetric_keynames)
          end
        end

        it_behaves_like :check_symmetry do
          subject { dept_bridge_base }
          let(:bases) do
            [
              subject,
              dept_dimer_base,
              dept_methyl_on_bridge_base,
              dept_methyl_on_dimer_base
            ]
          end
          let(:specifics) { [dept_activated_bridge] }
          let(:symmetry_classes) { [] }
          let(:symmetric_keynames) { [] }
        end

        it_behaves_like :check_symmetry do
          subject { dept_methyl_on_bridge_base }
          let(:bases) { [dept_bridge_base, subject] }
          let(:specifics) { [dept_activated_methyl_on_bridge] }
          let(:typical_reactions) { [dept_methyl_incorporation] }
          let(:symmetry_classes) { [] }
          let(:symmetric_keynames) { [] }
        end

        it_behaves_like :check_symmetry do
          subject { dept_activated_methyl_on_bridge }
          let(:bases) { [dept_bridge_base, dept_methyl_on_bridge_base] }
          let(:specifics) { [subject] }
          let(:typical_reactions) { [dept_methyl_incorporation] }
          let(:symmetry_classes) do
            ['AtomsSwapWrapper<EmptySpecific<METHYL_ON_BRIDGE_CMs>, 2, 3>']
          end
          let(:symmetric_keynames) { [:cr, :cl] }
        end

        it_behaves_like :check_symmetry do
          subject { dept_methyl_on_dimer_base }
          let(:bases) do
            [dept_bridge_base, dept_methyl_on_bridge_base, subject]
          end
          let(:specifics) { [dept_activated_methyl_on_dimer] }
          let(:typical_reactions) { [dept_hydrogen_migration] }
          let(:symmetry_classes) { [] }
          let(:symmetric_keynames) { [] }
        end

        describe 'symmetric dimers' do
          subject { dept_dimer_base }
          let(:bases) { [dept_bridge_base, subject] }

          [:cl, :cr, :crb, :_cr0, :clb, :_cr1].each do |keyname|
            let(keyname) { dimer_base.atom(keyname) }
          end

          it_behaves_like :check_symmetry do
            let(:specifics) { [dept_twise_incoherent_dimer] }
            let(:typical_reactions) { [dept_incoherent_dimer_drop] }
            let(:symmetry_classes) { [] }
            let(:symmetric_keynames) { [] }
          end

          it_behaves_like :check_symmetry do
            let(:specifics) { [dept_activated_dimer, dept_twise_incoherent_dimer] }
            let(:typical_reactions) do
              [dept_hydrogen_migration, dept_incoherent_dimer_drop]
            end
            let(:symmetry_classes) do
              ['ParentsSwapWrapper<EmptyBase<DIMER>, OriginalDimer, 0, 1>']
            end
            let(:symmetric_keynames) { [:cr, :cl] }

            it { expect(detector.symmetric_atoms(cr)).to match_array([cr, cl]) }
            it { expect(detector.symmetric_atoms(cl)).to match_array([cr, cl]) }
            it { expect(detector.symmetric_atoms(crb)).to be_empty }
            it { expect(detector.symmetric_atoms(_cr0)).to be_empty }
            it { expect(detector.symmetric_atoms(clb)).to be_empty }
            it { expect(detector.symmetric_atoms(_cr1)).to be_empty }
          end

          it_behaves_like :check_symmetry do
            let(:specifics) { [] }
            let(:typical_reactions) do
              [dept_incoherent_dimer_drop, dept_one_dimer_hydrogen_migration]
            end
            let(:symmetry_classes) do
              ['ParentsSwapWrapper<EmptyBase<DIMER>, OriginalDimer, 0, 1>']
            end
            let(:symmetric_keynames) { [:cr, :cl] }
          end

          it_behaves_like :check_symmetry do
            let(:specifics) { [dept_bottom_hydrogenated_activated_dimer] }
            let(:typical_reactions) { [dept_bhad_activation] }
            let(:symmetry_classes) do
              [
                'AtomsSwapWrapper<EmptyBase<DIMER>, 1, 2>',
                'ParentsSwapWrapper<EmptyBase<DIMER>, OriginalDimer, 0, 1>',
                'AtomsSwapWrapper<ParentsSwapWrapper<EmptyBase<DIMER>, OriginalDimer, 0, 1>, 1, 2>'
              ]
            end
            let(:symmetric_keynames) { [:cr, :cl, :crb, :clb, :_cr0, :_cr1] }

            it { expect(detector.symmetric_atoms(cl)).to match_array([cr, cl]) }
            it { expect(detector.symmetric_atoms(cr)).to match_array([cr, cl]) }

            let(:all_bottom) { [crb, _cr0, _cr1, clb] }
            it { expect(detector.symmetric_atoms(crb)).to match_array(all_bottom) }
            it { expect(detector.symmetric_atoms(_cr0)).to match_array(all_bottom) }
            it { expect(detector.symmetric_atoms(clb)).to match_array(all_bottom) }
            it { expect(detector.symmetric_atoms(_cr1)).to match_array(all_bottom) }
          end
        end

        describe 'dimer children' do
          let(:bases) { [dept_bridge_base, dept_dimer_base] }
          let(:specifics) { [subject] }

          describe 'incoherent dimer' do
            let(:typical_reactions) do
              [dept_incoherent_dimer_drop, dept_one_dimer_hydrogen_migration]
            end

            it_behaves_like :check_symmetry do
              subject { dept_twise_incoherent_dimer }
              let(:symmetry_classes) do
                ['ParentsSwapProxy<OriginalDimer, SymmetricDimer, DIMER_CLi_CRi>']
              end
              let(:symmetric_keynames) { [:cr, :cl] }
            end

            it_behaves_like :check_symmetry do
              subject { dept_activated_incoherent_dimer }
              let(:symmetry_classes) { [] }
              let(:symmetric_keynames) { [] }
            end
          end

          describe 'activated dimer' do
            subject { dept_activated_dimer }
            let(:specifics) { [subject, specific] }
            let(:use_parent_symmetry) { true }

            it_behaves_like :check_symmetry do
              let(:specific) { dept_bottom_hydrogenated_activated_dimer }
              let(:typical_reactions) { [dept_bhad_activation] }
              let(:symmetry_classes) do
                ['AtomsSwapWrapper<EmptyBase<DIMER_CRs>, 4, 5>']
              end
              let(:symmetric_keynames) { [:_cr1, :clb] }

              let(:clb) { activated_dimer.atom(:clb) }
              let(:_cr1) { activated_dimer.atom(:_cr1) }
              it { expect(detector.symmetric_atoms(clb)).to match_array([clb, _cr1]) }
              it { expect(detector.symmetric_atoms(_cr1)).to match_array([clb, _cr1]) }
            end

            it_behaves_like :check_symmetry do
              let(:faked_rbhad) do
                fake_reaction.apply_to!(dept_right_bottom_hydrogenated_activated_dimer)
              end
              let(:specific) { faked_rbhad }
              let(:symmetry_classes) do
                ['AtomsSwapWrapper<EmptyBase<DIMER_CRs>, 1, 2>']
              end
              let(:symmetric_keynames) { [:_cr0, :crb] }

              let(:crb) { activated_dimer.atom(:crb) }
              let(:_cr0) { activated_dimer.atom(:_cr0) }
              it { expect(detector.symmetric_atoms(crb)).to match_array([crb, _cr0]) }
              it { expect(detector.symmetric_atoms(_cr0)).to match_array([crb, _cr0]) }
            end
          end
        end

        it_behaves_like :check_symmetry do
          subject { dept_cross_bridge_on_bridges_base }
          let(:bases) { [subject, dept_methyl_on_bridge_base] }
          let(:specifics) { [] }
          let(:typical_reactions) { [dept_sierpinski_drop] }
          let(:symmetry_classes) do
            ['ParentsSwapWrapper<EmptySpecific<CROSS_BRIDGE_ON_BRIDGES>, ' \
              'OriginalCrossBridgeOnBridges, 0, 1>']
          end

          let(:symmetric_keynames) { [:ctl, :ctr] }
          let(:ctl) { cross_bridge_on_bridges_base.atom(:ctl) }
          let(:ctr) { cross_bridge_on_bridges_base.atom(:ctr) }
          it { expect(detector.symmetric_atoms(ctr)).to match_array([ctr, ctl]) }
          it { expect(detector.symmetric_atoms(ctl)).to match_array([ctr, ctl]) }
        end
      end

    end
  end
end
