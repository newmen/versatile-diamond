require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe Env, use: :engine_generator do
        let(:generator) { stub_generator(specific_specs: [methyl]) }
        subject { described_class.new(generator) }

        describe '#file_name' do
          it { expect(subject.file_name).to eq('env') }
        end

        describe '#concentration_name' do
          it { expect(subject.concentration_name(methyl)).to eq('MethaneCs') }
        end

        describe '#full_concentration_method' do
          let(:name) { subject.full_concentration_method(methyl) }
          it { expect(name).to eq('Env::cMethaneCs()') }
        end
      end

    end
  end
end
