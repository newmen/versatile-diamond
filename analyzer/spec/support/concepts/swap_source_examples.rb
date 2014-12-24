module VersatileDiamond
  module Concepts
    module Support

      module SwapSourceExamples
        shared_examples_for :check_specs_after_swap_source do
          let(:from) { dimer }
          let(:to) { dimer.dup }
          let(:before_size) { subject.send(method).size }
          before(:each) do
            before_size # count size before swap
            subject.swap_source(from, to)
          end

          it { expect(subject.send(method)).to include(to) }
          it { expect(subject.send(method)).not_to include(from) }
          it { expect(subject.send(method).size).to eq(before_size) }
        end
      end

    end
  end
end
