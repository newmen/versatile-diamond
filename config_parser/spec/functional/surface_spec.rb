require 'spec_helper'

module VersatileDiamond
  module Interpreter

    describe Surface, type: :interpreter do
      describe "#spec" do
        it "interpreted spec stores in Chest" do
          surface.interpret('spec :hello').
            should be_a(Interpreter::SurfaceSpec)

          Tools::Chest.surface_spec(:hello).should be_a(Concepts::SurfaceSpec)
        end
      end

      describe "#temperature" do
        describe "duplicating" do
          before { surface.interpret('temperature 100, C') }
          it { expect { surface.interpret('temperature 200, F') }.
            to raise_error syntax_error }
        end
      end

      describe "#lattice" do
        it { expect { surface.interpret('lattice :d') }.
          to raise_error syntax_error }

        it "lattice stores in Chest" do
          surface.interpret('lattice :x, cpp_class: Xenon')
          Tools::Chest.lattice(:x).should be_a(Concepts::Lattice)
        end
      end

      describe "#size" do
        [
          'size x: 2',
          'size y: 2',
          'size 2, 2',
        ].each do |str|
          it "wrong size line: '#{str}'" do
            expect { surface.interpret(str) }.to raise_error
          end
        end

        describe "duplicating" do
          before { surface.interpret('size x: 20, y: 20') }
          it { expect { surface.interpret('size x: 2, y: 2') }.
            to raise_error syntax_error }
        end
      end

      describe "#composition" do
        before(:each) do
          elements.interpret('atom C, valence: 4')
        end

        it "wrong atom" do
          expect { surface.interpret('composition C') }.
            to raise_error syntax_error
        end

        describe "duplicating" do
          before do
            surface.interpret('lattice :d, cpp_class: Diamond')
            surface.interpret('composition C%d')
          end
          it { expect { surface.interpret('composition C%d') }.
            to raise_error syntax_error }
        end
      end
    end

  end
end
