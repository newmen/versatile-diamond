module VersatileDiamond
  module Organizers
    module Support

      module TargetsProcessorExamples
        shared_examples_for :check_mapped_targets do
          before { reaction.send(:store_parent, dept_dimer_formation) }
          subject { chunk.mapped_targets }
          it { expect(subject).to be_a(Hash) }
          # check that keys and values are targets
          it { expect(subject.flatten(2).size).to eq(subject.size * 4) }
          it { expect(subject.flatten(2)).not_to include(nil) }
        end
      end

    end
  end
end
