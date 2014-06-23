require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe Atom do
        subject { described_class.new(c) }

        describe '#file_name' do
          it { expect(subject.file_name).to eq('c') }
        end

        describe '#class_name' do
          it { expect(subject.class_name).to eq('C') }
        end
      end

    end
  end
end
