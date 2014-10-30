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

      describe '#root_species' do
        subject { stub_generator(base_specs: dept_specs) }
        let(:dept_specs) do
          [dept_bridge_base, dept_methyl_on_bridge_base, dept_dimer_base]
        end
        let(:root_species) do
          [subject.specie_class(:bridge), subject.specie_class(:dimer)]
        end

        it { expect(subject.root_species).to match_array(root_species) }
      end

      describe '#specific_gas_species' do
        let(:bases) { [dept_methane_base] }
        let(:specifics) { [dept_methyl, dept_activated_bridge] }
        subject { stub_generator(base_specs: bases, specific_specs: specifics) }
        let(:gas_specs) { subject.specific_gas_species }
        let(:gas_names) { [:"methane(c: *)", :"hydrogen(h: *)"] }

        before do
          Tools::Config.gas_concentration(methyl, 1, 'mol/l')
          Tools::Config.gas_concentration(hydrogen_ion, 2, 'mol/l')
        end

        it { expect(gas_specs.map(&:name)).to match_array(gas_names) }
      end
    end

  end
end
