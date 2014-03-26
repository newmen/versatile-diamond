module VersatileDiamond
  module Concepts
    module Support

      module TerminationSpecExamples
        shared_examples_for "termination spec" do
          it { expect(subject).to be_a(TerminationSpec) }

          describe "#is_gas?" do
            it { expect(subject.is_gas?).to be_false }
          end

          describe "#simple?" do
            it { expect(subject.simple?).to be_false }
          end

          describe "#extendable?" do
            it { expect(subject.extendable?).to be_false }
          end

          describe "#size" do
            it { expect(subject.size).to eq(1) }
          end
        end
      end

    end
  end
end
