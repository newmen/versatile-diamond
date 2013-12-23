require 'spec_helper'

module VersatileDiamond
  module Mcs

    describe Graph do
      let(:propane) do
        s = Concepts::GasSpec.new(:propane, a: c0, b: c1, c: c2)
        s.link(c0, c1, free_bond)
        s.link(c1, c2, free_bond); s
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
          it { vertices.should include(c0, c1, c2) }
        end
      end

      describe "#edge" do
        it { graph.edge(c0, c1).should == free_bond }
        it { graph.edge(c1, c2).should == free_bond }
        it { graph.edge(c0, c2).should be_nil }
      end

      describe "#edges" do
        it { graph.edges(c0, c1).size.should == 1 }
        it { graph.edges(c1, c2).size.should == 1 }
        it { graph.edges(c0, c2).size.should == 0 }
      end

      describe "#lattices" do
        it { graph.lattices.should == [nil] }

        describe "one of atoms has lattice" do
          before(:each) { c2.lattice = diamond }

          it { graph.lattices.size.should == 2 }
          it { graph.lattices.should include(nil, diamond) }
        end
      end

      describe "changing lattice" do
        before(:each) { graph.change_lattice!(c2, diamond) }

        describe "#change_lattice!" do
          it { vertices.size.should == 3 }
          it { graph.lattices.size.should == 2 }
          it { graph.lattices.should include(nil, diamond) }
        end

        let(:new_c) { (vertices - [c0, c1]).first }

        describe "#changed_vertex" do
          it { graph.changed_vertex(c0).should be_nil }
          it { graph.changed_vertex(c1).should be_nil }
          it { graph.changed_vertex(new_c).should == c2 }
        end

        describe "#vertex_changed_to" do
          it { graph.vertex_changed_to(c2).should == new_c }
        end

        describe "deep changing" do
          before(:each) { graph.change_lattice!(new_c, nil) }

          # there need to direct get graph vertices
          let(:new_new) { (graph.each_vertex.to_a - [c0, c1]).first }

          it { new_new.should_not == c2 }
          it { new_new.should_not == new_c }

          it { graph.changed_vertex(new_new).should == c2 }
          it { graph.vertex_changed_to(c2).should == new_new }
        end
      end

      describe "#select_vertices" do
        it { graph.select_vertices([c0, c1]).size.should == 2 }
        it { graph.select_vertices([c0, c1]).should include(c0, c1) }
      end

      describe "#remaining_vertices" do
        it { graph.remaining_vertices([c0, c2]).should == [c1] }
      end

      describe "#boundary_vertices" do
        it { graph.boundary_vertices([c0]).should == [c1] }
        it { graph.boundary_vertices([c0, c1]).should == [c2] }
        it { graph.boundary_vertices([c0, c2]).should == [c1] }
      end

      describe "#remove_edges!" do
        describe "only one vertex" do
          before(:each) { graph.remove_edges!([c1]) }

          it { graph.edge(c0, c1).should == free_bond }
          it { graph.edge(c1, c2).should == free_bond }
        end

        describe "two vertices" do
          before(:each) { graph.remove_edges!([c0, c1]) }

          it { graph.edge(c0, c1).should be_nil }
          it { graph.edge(c1, c2).should == free_bond }
        end
      end

      describe "#remove_vertices!" do
        describe "boundary vertex" do
          before(:each) { graph.remove_vertices!([c0]) }

          it { vertices.size.should == 2 }
          it { vertices.should include(c1, c2) }
          it { graph.edge(c0, c1).should be_nil }
          it { graph.edge(c1, c2).should == free_bond }
        end

        describe "central vertex" do
          before(:each) { graph.remove_vertices!([c1]) }

          it { vertices.size.should == 2 }
          it { vertices.should include(c0, c2) }
          it { graph.edge(c0, c1).should be_nil }
          it { graph.edge(c1, c2).should be_nil }
        end

        describe "two vertices" do
          before(:each) { graph.remove_vertices!([c0, c1]) }
          it { vertices.should == [c2] }
        end
      end

      describe "#remove_disconnected_vertices!" do
        describe "boundary vertex" do
          before(:each) do
            graph.remove_vertices!([c0])
            graph.remove_disconnected_vertices!
          end

          it { vertices.size.should == 2 }
          it { vertices.should include(c1, c2) }
        end

        describe "central vertex" do
          before(:each) do
            graph.remove_vertices!([c1])
            graph.remove_disconnected_vertices!
          end

          it { vertices.should be_empty }
        end
      end
    end

  end
end
