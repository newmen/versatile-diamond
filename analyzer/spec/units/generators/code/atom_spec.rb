require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe Atom do
        subject { described_class.new(c) }

        describe '#template_name' do
          it { expect(subject.template_name).to eq('atom') }
        end

        describe '#file_name' do
          it { expect(subject.file_name).to eq('c') }
        end

        describe '#define_name' do
          it { expect(subject.define_name).to eq('C_H') }
        end

        describe '#class_name' do
          it { expect(subject.class_name).to eq('C') }
        end
      end

    end
  end
end
