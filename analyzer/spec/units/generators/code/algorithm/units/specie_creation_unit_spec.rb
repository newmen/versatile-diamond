require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        describe SpecieCreationUnit, type: :algorithm do
          subject { described_class.new(dict, context, specie) }
          let(:context) { SpecieContext.new(dict, backbone.big_graph, ordered_graph) }
          let(:specie) { generator.specie_class(dept_uniq_specie.name) }
          let(:bone_nodes) { context.bone_nodes }
          let(:addition_atoms) { specie.sequence.addition_atoms }

          describe '#create' do
            describe 'from major atoms which already arr' do
              include_context :bridge_context
              before { dict.make_atom_s(bone_nodes.map(&:atom)) }
              it { expect(subject.create.code).to eq('create<Bridge>(atoms1)') }
            end

            describe 'from major atoms not same arr' do
              include_context :bridge_context
              before do
                first, *nodes = bone_nodes
                dict.make_atom_s(first.atom)
                dict.make_atom_s(nodes.map(&:atom))
              end
              let(:code) do
                <<-CODE
Atom *atoms2[3] = { atom1, atoms1[0], atoms1[1] };
create<Bridge>(atoms2);
                CODE
              end
              it { expect(subject.create.code).to eq(code.rstrip) }
            end

            describe 'from parent species' do
              let(:parent_species) do
                bone_nodes.map(&:uniq_specie).reject(&:none?).uniq
              end

              describe 'which already arr' do
                include_context :two_mobs_context
                before do
                  instances_type = Expressions::ParentSpecieType[]
                  dict.make_specie_s(parent_species, type: instances_type)
                end
                let(:code) { 'create<CrossBridgeOnBridges>(species1)' }
                it { expect(subject.create.code).to eq(code) }
              end

              describe 'not same arr' do
                include_context :two_mobs_context
                before { parent_species.map(&dict.public_method(:make_specie_s)) }
                let(:code) do
                  <<-CODE
ParentSpec *parents[2] = { methylOnBridge1, methylOnBridge2 };
create<CrossBridgeOnBridges>(parents);
                  CODE
                end
                it { expect(subject.create.code).to eq(code.rstrip) }
              end

              describe 'with one additional atom' do
                include_context :mob_context
                before do
                  dict.make_atom_s(addition_atoms)
                  dict.make_specie_s(parent_species)
                end
                let(:code) { 'create<MethylOnBridge>(amorph1, bridge1)' }
                it { expect(subject.create.code).to eq(code) }
              end
            end
          end
        end

      end
    end
  end
end
