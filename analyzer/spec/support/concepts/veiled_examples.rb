require 'spec_helper'

module VersatileDiamond
  module Concepts

    module VeiledExamples
      shared_examples_for :check_same_veiled do
        let(:veiled) { described_class.new(subject) }

        it { expect(subject.same?(veiled)).to be_truthy }
        it { expect(veiled.same?(subject)).to be_truthy }

        let(:other_veiled) { described_class.new(other) }
        it { expect(veiled.same?(other_veiled)).to be_falsey }
        it { expect(other_veiled.same?(veiled)).to be_falsey }
      end
    end

  end
end
