module VersatileDiamond
  module Organizers
    module Support

      module AtomRelationsExamples
        shared_examples_for :relations_of do
          it { expect(subject.relations_of(atom)).to match_array(rls) }
        end
      end

    end
  end
end
