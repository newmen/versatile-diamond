require 'spec_helper'

module VersatileDiamond
  module Interpreter

    describe SurfaceSpec, type: :interpreter do
      let(:concept) { Concepts::Spec.new(:spec_name) }
      let(:spec) { Interpreter::SurfaceSpec.new(concept) }

      before(:each) do
        elements.interpret('atom N, valence: 3')
        surface.interpret('lattice :nh4, cpp_class: Ammonia')
      end

      describe "#position" do
        describe "both atoms has lattice" do
          before(:each) do
            spec.interpret('atoms n1: N%nh4, n2: N%nh4')
          end

          it { expect { spec.interpret('position :n1, :n2, face: 100') }.
            to raise_error syntax_error }

          it { expect { spec.interpret('position :n1, :n2, dir: :front') }.
            to raise_error syntax_error }

          it { expect {
              spec.interpret('position :n1, :n2, face: 100, dir: :front')
            }.to_not raise_error }
        end

        describe "only one atom has lattice" do
          before(:each) do
            spec.interpret('atoms n1: N%nh4, n2: N')
          end

          it { expect {
              spec.interpret('position :n1, :n2, face: 100, dir: :front')
            }.to raise_error syntax_error }
        end
      end
    end

  end
end
