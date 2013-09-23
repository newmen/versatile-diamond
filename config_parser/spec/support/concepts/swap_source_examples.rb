module VersatileDiamond
  module Concepts
    module Support

      module SwapSourceExamples
        shared_examples_for "#swap_source" do
          let(:from) { dimer }
          let(:to) { dimer_dup_ff }
          let(:before_size) { subject.specs.size }
          before(:each) do
            before_size # count size before swap
            subject.swap_source(from, to)
          end

          it { subject.specs.should include(to) }
          it { subject.specs.should_not include(from) }
          it { subject.specs.size.should == before_size }
        end
      end

    end
  end
end
