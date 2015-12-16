require 'spec_helper'

module VersatileDiamond
  module Generators

    describe EngineCode, use: :engine_generator do
      describe 'major code instances' do
        subject { stub_generator(base_specs: [dept_bridge_base]) }

        describe '#handbook' do
          it { expect(subject.handbook).to be_a(Code::Handbook) }
        end

        describe '#finder' do
          it { expect(subject.finder).to be_a(Code::Finder) }
        end

        describe '#env' do
          it { expect(subject.env).to be_a(Code::Env) }
        end

        describe '#atom_builder' do
          it { expect(subject.atom_builder).to be_a(Code::AtomBuilder) }
        end
      end

      describe '#unique_pure_atoms' do
        let(:bases) { [dept_methane_base, dept_bridge_base] }
        let(:specifics) { [dept_chlorigenated_bridge] }
        subject { stub_generator(base_specs: bases, specific_specs: specifics) }

        it { expect(subject.unique_pure_atoms.map(&:class_name)).to eq(['C']) }
      end

      describe '#lattices' do
        subject { stub_generator(base_specs: [dept_methane_base, dept_bridge_base]) }
        it { expect(subject.lattices.size).to eq(1) }

        let(:lattice) { subject.lattices.first }
        it { expect(lattice).to be_a(Code::Lattice) }
        it { expect(lattice.class_name).to eq('Diamond') }
      end

      describe '#lattice_class' do
        subject do
          stub_generator(base_specs: [dept_bridge_base, dept_methyl_on_bridge_base])
        end

        let(:lattice) { subject.lattice_class(diamond) }
        it { expect(lattice).to be_a(Code::Lattice) }

        let(:no_lattice) { subject.lattice_class(nil) }
        it { expect(no_lattice).to be_nil }
      end

      describe '#specie_class' do
        subject { stub_generator(base_specs: [dept_bridge_base]) }
        let(:specie) { subject.specie_class(dept_bridge_base.name) }
        it { expect(specie).to be_a(Code::Specie) }
        it { expect(specie.class_name).to eq('Bridge') }
      end

      describe 'basic species' do
        subject do
          stub_generator(base_specs: dept_specs, typical_reactions: dept_reactions)
        end
        let(:dept_specs) do
          [dept_bridge_base, dept_methyl_on_bridge_base, dept_dimer_base]
        end
        let(:dept_reactions) do
          [dept_dimer_formation, dept_methyl_activation, dept_hydrogen_migration]
        end

        let(:target_species) { names.map(&subject.method(:specie_class)) }

        describe '#root_species' do
          let(:names) { [:bridge, :dimer, :methyl_on_dimer] }
          it { expect(subject.root_species).to match_array(target_species) }
        end

        describe '#surface_species' do
          let(:names) do
            [
              :bridge, :dimer, # basic species
              :'bridge(ct: *)', :'bridge(ct: *, ct: i)', # dimer formation
              :methyl_on_bridge, # methyl activation
              :methyl_on_dimer, :'dimer(cr: *)', # hydrogen migration
            ]
          end
          it { expect(subject.surface_species).to match_array(target_species) }
        end
      end

      describe '#specific_gas_specs' do
        let(:bases) { [dept_methane_base] }
        let(:specifics) { [dept_hydrogen_ion, dept_methyl, dept_activated_bridge] }
        subject { stub_generator(base_specs: bases, specific_specs: specifics) }
        let(:gas_specs) { subject.specific_gas_specs }
        let(:gas_names) { [:"methane(c: *)", :"hydrogen(h: *)"] }

        it { expect(gas_specs.map(&:name)).to match_array(gas_names) }
      end

      describe '#many_times?' do
        let(:dept_specs) { [dept_bridge_base, dept_methyl_on_bridge_base] }
        let(:dept_reactions) { [dept_dimer_formation, dept_sierpinski_drop] }
        subject do
          stub_generator(base_specs: dept_specs, typical_reactions: dept_reactions)
        end

        let(:latticed_too) { true }
        shared_examples_for :check_many_times do
          let(:atom) { spec.spec.atom(keyname) }
          let(:value) { subject.many_times?(spec, atom, latticed_too: latticed_too) }
          it { expect(value).to eq(result) }
        end

        describe 'bridge atoms' do
          let(:spec) { dept_bridge_base }

          it_behaves_like :check_many_times do
            let(:keyname) { :ct }
            let(:result) { false }
          end

          describe 'with latticed props' do
            it_behaves_like :check_many_times do
              let(:keyname) { :cr }
              let(:result) { true }
            end
          end

          describe 'without latticed props' do
            let(:latticed_too) { false }
            let(:keyname) { :cr }

            describe 'with many user specie' do
              let(:dept_specs) { [dept_bridge_base, dept_three_bridges_base] }
              let(:dept_reactions) { [dept_dimer_formation] }
              it_behaves_like :check_many_times do
                let(:result) { true }
              end
            end

            describe 'with formation reaction' do
              let(:dept_reactions) { [dept_dimer_formation, dept_methyl_to_gap] }
              it_behaves_like :check_many_times do
                let(:result) { true }
              end
            end

            describe 'without formation reaction' do
              it_behaves_like :check_many_times do
                let(:result) { false }
              end
            end
          end
        end

        describe 'methyl on bridge atoms' do
          let(:spec) { dept_methyl_on_bridge_base }

          it_behaves_like :check_many_times do
            let(:keyname) { :cb }
            let(:result) { false }
          end

          it_behaves_like :check_many_times do
            let(:keyname) { :cm }
            let(:result) { true }
          end
        end

        describe 'dimer atoms' do
          it_behaves_like :check_many_times do
            let(:spec) { dept_dimer_base }
            let(:keyname) { :cr }
            let(:result) { false }
          end
        end
      end
    end

  end
end
