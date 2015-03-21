module VersatileDiamond
  module Concepts
    module Support

      module TerminationSpecExamples
        shared_examples_for :termination_spec do
          it { expect(subject).to be_a(TerminationSpec) }

          describe '#gas?' do
            it { expect(subject.gas?).to be_falsey }
          end

          describe '#simple?' do
            it { expect(subject.simple?).to be_falsey }
          end

          describe '#extendable?' do
            it { expect(subject.extendable?).to be_falsey }
          end
        end
      end

    end
  end
end
