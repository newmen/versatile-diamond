require 'spec_helper'

module VersatileDiamond
  module Interpreter

    describe Dimensions, type: :interpreter do
      describe '#temperature' do
        [
          "temperature 'C'",
          "concentration 'mol/l'",
          "energy 'kJ/mol'",
          "rate '1/s'",
          "time 'min'"
        ].each do |line|
          it { expect { dimensions.interpret(line) }.
            not_to raise_error }
        end
      end

    end

  end
end
