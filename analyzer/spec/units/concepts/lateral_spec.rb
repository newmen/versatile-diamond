require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe Lateral do
      subject { dimers_row.make_lateral(one: 1, two: 2) }

      describe "#there" do
        it { expect(subject.there(at_end)).to be_a(There) }
      end
    end

  end
end
