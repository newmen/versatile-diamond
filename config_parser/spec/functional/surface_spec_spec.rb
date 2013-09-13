require 'spec_helper'

module VersatileDiamond
  module Interpreter

    describe SurfaceSpec, type: :interpreter do
      let(:concept) { Concepts::SurfaceSpec.new(:spec_name) }
      let(:spec) { Interpreter::SurfaceSpec.new(concept) }

      before(:each) do
        interpret_basis
      end

      describe "#position" do
        describe "both atoms has lattice" do
          let(:uncomplete) { syntax_error('position.uncomplete') }

          before(:each) do
            spec.interpret('atoms c1: C%d, c2: C%d')
          end

          it { expect { spec.interpret('position :c1, :c2, face: 100') }.
            to raise_error uncomplete }

          it { expect { spec.interpret('position :c1, :c2, dir: :front') }.
            to raise_error uncomplete }

          it { expect {
              spec.interpret('position :c1, :c2, face: 100, dir: :front')
            }.to_not raise_error }
        end

        describe "only one atom has lattice" do
          before(:each) do
            spec.interpret('atoms c1: C%d, c2: C')
          end

          it { expect {
              spec.interpret('position :c1, :c2, face: 100, dir: :front')
            }.to raise_error syntax_error(
              'surface_spec.wrong_relation', relation: position_front) }
        end
      end
    end

  end
end
