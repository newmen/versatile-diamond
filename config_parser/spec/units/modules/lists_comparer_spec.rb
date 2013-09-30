require 'spec_helper'

module VersatileDiamond
  module Modules

    describe ListsComparer do
      class SomeComparer
        include ListsComparer
      end
      subject { SomeComparer.new }

      describe "#lists_are_identical?" do
        let(:list1) { [1, 2, 3] }
        let(:list2) { [3, 1, 2] }
        let(:short_list) { [1, 2] }
        let(:another_list) { [1, 2, :three] }
        let(:block) { -> v, w { v == w } }

        it { subject.lists_are_identical?(list1, list2, &block).
          should be_true }

        it { subject.lists_are_identical?(list1, short_list, &block).
          should be_false }

        it { subject.lists_are_identical?(list1, another_list, &block).
          should be_false }
      end
    end

  end
end
