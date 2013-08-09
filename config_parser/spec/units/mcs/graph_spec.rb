require 'spec_helper'

module VersatileDiamond
  module Mcs

    describe Graph do
      let(:lattice) { Concepts::Lattice.new(:d, 'Diamond') }
      let(:free_bond) { Concepts::Bond[face: nil, dir: nil] }
      let(:a) { Concepts::Atom.new('C', 4) }
      let(:b) { a.dup }
      let(:c) { a.dup }
      let(:propane) do
        s = Concepts::Spec.new(:propane, a: a, b: b, c: c)
        s.link(a, b, free_bond)
        s.link(b, c, free_bond); s
      end

      let(:graph) { described_class.new(propane.links) }
      let(:vertices) { graph.each_vertex.to_a }

      describe "#each_vertex" do
        it { graph.each_vertex.should be_a(Enumerable) }
        it { vertices.size.should == 3 }

        describe "with block" do
          let(:vertices) do
            vs = []
            graph.each_vertex { |v| vs << v }
            vs
          end

          it { vertices.size.should == 3 }
          it { vertices.should include(a, b, c) }
        end
      end

      describe "#edge" do
        it { graph.edge(a, b).should == free_bond }
        it { graph.edge(b, c).should == free_bond }
        it { graph.edge(a, c).should be_nil }
      end

      describe "#edges" do
        it { graph.edges(a, b).size.should == 1 }
        it { graph.edges(b, c).size.should == 1 }
        it { graph.edges(a, c).size.should == 0 }
      end

      describe "#lattices" do
        it { graph.lattices.should == [nil] }

        describe "one of atoms has lattice" do
          before(:each) { c.lattice = lattice }

          it { graph.lattices.size.should == 2 }
          it { graph.lattices.should include(nil, lattice) }
        end
      end

      describe "changing lattice" do
        before(:each) { graph.change_lattice!(c, lattice) }

        describe "#change_lattice!" do
          it { vertices.size.should == 3 }
          it { graph.lattices.size.should == 2 }
          it { graph.lattices.should include(nil, lattice) }
        end

        let(:new_c) { (vertices - [a, b]).first }

        describe "#changed_vertex" do
          it { graph.changed_vertex(a).should be_nil }
          it { graph.changed_vertex(b).should be_nil }
          it { graph.changed_vertex(new_c).should == c }
        end

        describe "#vertex_changed_to" do
          it { graph.vertex_changed_to(c).should == new_c }
        end

        describe "deep changing" do
          before(:each) { graph.change_lattice!(new_c, nil) }

          # there need to direct get graph vertices
          let(:new_new) { (graph.each_vertex.to_a - [a, b]).first }

          it { new_new.should_not == c }
          it { new_new.should_not == new_c }

          it { graph.changed_vertex(new_new).should == c }
          it { graph.vertex_changed_to(c).should == new_new }
        end
      end

      describe "#select_vertices" do
        it { graph.select_vertices([a, b]).size.should == 2 }
        it { graph.select_vertices([a, b]).should include(a, b) }
      end

      describe "#remaining_vertices" do
        it { graph.remaining_vertices([a, c]).should == [b] }
      end

      describe "#boundary_vertices" do
        it { graph.boundary_vertices([a]).should == [b] }
        it { graph.boundary_vertices([a, b]).should == [c] }
        it { graph.boundary_vertices([a, c]).should == [b] }
      end

      describe "#remove_edges!" do
        describe "only one vertex" do
          before(:each) { graph.remove_edges!([b]) }

          it { graph.edge(a, b).should == free_bond }
          it { graph.edge(b, c).should == free_bond }
        end

        describe "two vertices" do
          before(:each) { graph.remove_edges!([a, b]) }

          it { graph.edge(a, b).should be_nil }
          it { graph.edge(b, c).should == free_bond }
        end
      end

      describe "#remove_vertices!" do
        describe "boundary vertex" do
          before(:each) { graph.remove_vertices!([a]) }

          it { vertices.size.should == 2 }
          it { vertices.should include(b, c) }
          it { graph.edge(a, b).should be_nil }
          it { graph.edge(b, c).should == free_bond }
        end

        describe "central vertex" do
          before(:each) { graph.remove_vertices!([b]) }

          it { vertices.size.should == 2 }
          it { vertices.should include(a, c) }
          it { graph.edge(a, b).should be_nil }
          it { graph.edge(b, c).should be_nil }
        end

        describe "two vertices" do
          before(:each) { graph.remove_vertices!([a, b]) }
          it { vertices.should == [c] }
        end
      end

      describe "#remove_disconnected_vertices!" do
        describe "boundary vertex" do
          before(:each) do
            graph.remove_vertices!([a])
            graph.remove_disconnected_vertices!
          end

          it { vertices.size.should == 2 }
          it { vertices.should include(b, c) }
        end

        describe "central vertex" do
          before(:each) do
            graph.remove_vertices!([b])
            graph.remove_disconnected_vertices!
          end

          it { vertices.should be_empty }
        end
      end
    end

  end
end
