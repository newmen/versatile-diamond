require 'spec_helper'

module VersatileDiamond
  module Interpreter

    describe Dimensions do
      let(:dimensions) { Dimensions.new }

      describe "#temperature" do
        [
          "temperature 'C'",
          "concentration 'mol/l'",
          "energy 'kJ/mol'",
          "rate '1/s'",
          "time 'min'"
        ].each do |line|
          it { -> { dimensions.interpret(line) }.
            should_not raise_error Exception }
        end
      end

    end

  end
end
