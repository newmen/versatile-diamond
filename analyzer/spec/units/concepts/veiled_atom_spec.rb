require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe VeiledAtom do
      describe '#same?' do
        it_behaves_like :check_same_veiled do
          subject { cd }
          let(:other) { c }
        end

        it_behaves_like :check_same_veiled do
          subject { activated_cd }
          let(:other) { activated_c }
        end
      end

    end
  end
end
