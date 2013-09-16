module VersatileDiamond
  module Concepts
    module Support

      module SwapSourceExamples
        shared_examples_for "#swap_source" do
          let(:from) { dimer }
          let(:to) { dimer_dup_ff }
          before(:each) { subject.swap_source(from, to) }

          it { subject.specs.should include(to) }
          it { subject.specs.should_not include(from) }
        end
      end

    end
  end
end
