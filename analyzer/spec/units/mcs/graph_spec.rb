require 'spec_helper'

module VersatileDiamond
  module Mcs

    describe Graph do
      let(:propane) do
        s = Concepts::GasSpec.new(:propane, a: c0, b: c1, c: c2)
        s.link(c0, c1, free_bond)
        s.link(c1, c2, free_bond); s
      end

      let(:graph) { described_class.new(propane) }
      let(:vertices) { graph.each_vertex.to_a }

      describe '#each_vertex' do
        it { expect(graph.each_vertex).to be_a(Enumerable) }
        it { expect(vertices).to match_array([c0, c1, c2]) }
      end

      describe '#edge' do
        it { expect(graph.edge(c0, c1)).to eq(free_bond) }
        it { expect(graph.edge(c1, c2)).to eq(free_bond) }
        it { expect(graph.edge(c0, c2)).to be_nil }
      end

      describe '#edges' do
        it { expect(graph.edges(c0, c1)).to match_array([free_bond]) }
        it { expect(graph.edges(c1, c2)).to match_array([free_bond]) }
        it { expect(graph.edges(c0, c2)).to be_empty }
      end

      describe '#lattices' do
        it { expect(graph.lattices).to eq([nil]) }

        describe 'one of atoms has lattice' do
          before { c2.lattice = diamond }
          it { expect(graph.lattices).to match_array([nil, diamond]) }
        end
      end

      describe 'changing lattice' do
        before(:each) { graph.change_lattice!(c2, diamond) }

        describe '#change_lattice!' do
          it { expect(vertices.size).to eq(3) }
          it { expect(graph.lattices).to match_array([nil, diamond]) }
        end

        let(:new_c) { (vertices - [c0, c1]).first }

        describe '#changed_vertex' do
          it { expect(graph.changed_vertex(c0)).to be_nil }
          it { expect(graph.changed_vertex(c1)).to be_nil }
          it { expect(graph.changed_vertex(new_c)).to eq(c2) }
        end

        describe '#vertex_changed_to' do
          it { expect(graph.vertex_changed_to(c2)).to eq(new_c) }
        end

        describe 'deep changing' do
          before(:each) { graph.change_lattice!(new_c, nil) }

          # there need to direct get graph vertices
          let(:new_new) { (graph.each_vertex.to_a - [c0, c1]).first }

          it { expect(new_new).not_to eq(c2) }
          it { expect(new_new).not_to eq(new_c) }

          it { expect(graph.changed_vertex(new_new)).to eq(c2) }
          it { expect(graph.vertex_changed_to(c2)).to eq(new_new) }
        end
      end

      describe '#select_vertices' do
        it { expect(graph.select_vertices([c0, c1])).to match_array([c0, c1]) }
      end

      describe '#remaining_vertices' do
        it { expect(graph.remaining_vertices([c0, c2])).to eq([c1]) }
      end

      describe '#boundary_vertices' do
        it { expect(graph.boundary_vertices([c0])).to eq([c1]) }
        it { expect(graph.boundary_vertices([c0, c1])).to eq([c2]) }
        it { expect(graph.boundary_vertices([c0, c2])).to eq([c1]) }
      end

      describe '#remove_edges!' do
        describe 'only one vertex' do
          before(:each) { graph.remove_edges!([c1]) }

          it { expect(graph.edge(c0, c1)).to eq(free_bond) }
          it { expect(graph.edge(c1, c2)).to eq(free_bond) }
        end

        describe 'two vertices' do
          before(:each) { graph.remove_edges!([c0, c1]) }

          it { expect(graph.edge(c0, c1)).to be_nil }
          it { expect(graph.edge(c1, c2)).to eq(free_bond) }
        end
      end

      describe '#remove_vertices!' do
        describe 'boundary vertex' do
          before(:each) { graph.remove_vertices!([c0]) }

          it { expect(vertices).to match_array([c1, c2]) }
          it { expect(graph.edge(c0, c1)).to be_nil }
          it { expect(graph.edge(c1, c2)).to eq(free_bond) }
        end

        describe 'central vertex' do
          before(:each) { graph.remove_vertices!([c1]) }

          it { expect(vertices).to match_array([c0, c2]) }
          it { expect(graph.edge(c0, c1)).to be_nil }
          it { expect(graph.edge(c1, c2)).to be_nil }
        end

        describe 'two vertices' do
          before { graph.remove_vertices!([c0, c1]) }
          it { expect(vertices).to eq([c2]) }
        end
      end

      describe '#remove_disconnected_vertices!' do
        describe 'boundary vertex' do
          before do
            graph.remove_vertices!([c0])
            graph.remove_disconnected_vertices!
          end

          it { expect(vertices).to match_array([c1, c2]) }
        end

        describe 'central vertex' do
          before(:each) do
            graph.remove_vertices!([c1])
            graph.remove_disconnected_vertices!
          end

          it { expect(vertices).to be_empty }
        end
      end
    end

  end
end
