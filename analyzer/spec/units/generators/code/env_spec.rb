require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe Env, use: :engine_generator do
        let(:generator) { stub_generator(specific_specs: [dept_methyl]) }
        subject { described_class.new(generator) }

        describe '#template_name' do
          it { expect(subject.template_name).to eq('env') }
        end

        describe '#file_name' do
          it { expect(subject.file_name).to eq('env') }
        end

        describe '#concentration_name' do
          it { expect(subject.concentration_name(methyl)).to eq('MethaneCs') }
        end

        describe '#full_concentration_method' do
          let(:name) { subject.full_concentration_method(dept_methyl) }
          it { expect(name).to eq('Env::cMethaneCs()') }
        end
      end

    end
  end
end
