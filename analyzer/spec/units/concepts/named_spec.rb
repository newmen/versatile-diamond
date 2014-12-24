require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe Named do
      describe '#name' do
        it { expect(Named.new('some').name).to eq(:some) }
      end
    end

  end
end
