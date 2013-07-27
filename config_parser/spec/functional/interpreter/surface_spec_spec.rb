require 'spec_helper'

module VersatileDiamond
  module Interpreter

    describe SurfaceSpec do
      let(:concept) { Concepts::Spec.new(:spec_name) }
      let(:spec) { Interpreter::SurfaceSpec.new(concept) }

      before(:each) do
        Tools::Chest.reset
        Elements.new.interpret('atom N, valence: 3')
        Surface.new.interpret('lattice :nh4, cpp_class: Ammonia')
      end

      describe "#position" do
        let(:syntax_error) { Errors::SyntaxError }

        describe "both atoms has lattice" do
          before(:each) do
            spec.interpret('atoms n1: N%nh4, n2: N%nh4')
          end

          it { -> { spec.interpret('position :n1, :n2, face: 100') }.
            should raise_error syntax_error }

          it { -> { spec.interpret('position :n1, :n2, dir: :front') }.
            should raise_error syntax_error }

          it { -> {
            spec.interpret('position :n1, :n2, face: 100, dir: :front')
            }.should_not raise_error syntax_error }
        end

        describe "only one atom has lattice" do
          before(:each) do
            spec.interpret('atoms n1: N%nh4, n2: N')
          end

          it { -> {
              spec.interpret('position :n1, :n2, face: 100, dir: :front')
            }.should raise_error syntax_error }
        end
      end
    end

  end
end
