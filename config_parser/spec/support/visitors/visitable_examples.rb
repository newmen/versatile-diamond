module VersatileDiamond
  module Visitors
    module Support

      module VisitableExamples
        shared_examples_for "visitable" do
          it { should respond_to(:visit).with(1).argument }
        end
      end

    end
  end
end
