module VersatileDiamond
  module Generators
    module Code

      # Accumulates all used atom sequences and creates new sequence if it's not
      # presented
      class SequencesCacher
        # Inits the cacher instance
        def initialize
          @sequences = {}
        end

        # Gets correspond atom sequence
        # @param [Organizers::DependentWrappedSpec] spec for which sequence will be
        #   gotten
        # @return [AtomSequence] the correspond atom sequence instance
        def get(spec)
          @sequences[spec] ||= AtomSequence.new(self, spec)
        end
      end

    end
  end
end
