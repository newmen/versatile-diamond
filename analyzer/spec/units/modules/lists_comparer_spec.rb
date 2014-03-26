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

        it { expect(subject.lists_are_identical?(list1, list2, &block)).
          to be_true }

        it { expect(subject.lists_are_identical?(list1, short_list, &block)).
          to be_false }

        it { expect(subject.lists_are_identical?(list1, another_list, &block)).
          to be_false }
      end
    end

  end
end
