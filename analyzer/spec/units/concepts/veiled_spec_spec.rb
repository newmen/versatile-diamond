require 'spec_helper'

module VersatileDiamond
  module Concepts

    describe VeiledSpec do
      describe '#same?' do
        it_behaves_like :check_same_veiled do
          subject { bridge_base }
          let(:other) { dimer_base }
        end

        it_behaves_like :check_same_veiled do
          subject { activated_bridge }
          let(:other) { activated_dimer }
        end
      end

    end
  end
end
